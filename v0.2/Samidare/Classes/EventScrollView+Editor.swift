//
//  EventScrollView+Editor.swift
//  Samidare
//
//  Created by Keisuke Kawamura on 2018/10/27.
//

import UIKit

extension EventScrollView {

    internal class Editor {

        internal enum State {
            case ready
            case editing
        }

        private enum Edge {
            case top
            case bottom
            case both
        }

        private weak var eventScrollView: EventScrollView?
        private let heavyImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
        private let lightImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        private let errorFeedbackGenerator = UINotificationFeedbackGenerator()
        private var addedLongPressGestureRecognizers: [UILongPressGestureRecognizer] = []

        private(set) var state: State = .ready

        /// Current editing EventCell.
        private weak var editingCell: EventCell?
        /// Copy of editingCell.event at begin editing such as 'top knob panning', 'bottom knob panning' and 'cell panning'.
        private var eventAtBeginEditing: Event?
        /// Copy of editingCell.frame at begin editing such as 'top knob panning', 'bottom knob panning' and 'cell panning'.
        private var cellFrameAtBeginEditing: CGRect?
        
        private weak var snapshotView: UIView?
        private weak var editingOverlayView: EditingOverlayView?

        /// First touch location in referencing EventScrollView.
        /// It's reset each time any gesture recognized.
        private var firstTouchLocation: CGPoint!
        /// Last touch location in referencing EventScrollView.
        private var lastTouchLocation: CGPoint!

        /// Tells editing has begun.
        internal var didBeginEditingHandler: (() -> Void)?
        
        internal var didEditHandler: (() -> Void)?

        init() {
            NotificationCenter.default.addObserver(self, selector: #selector(eventCellWillRemoveFromSuperview),
                                                   name: EventCell.willRemoveFromSuperviewNotification, object: nil)
        }
        deinit {
            NotificationCenter.default.removeObserver(self)
        }

        /// Setup Editor
        ///
        /// - Parameters:
        ///   - eventScrollView: EventScrollView to apply Editor function.
        ///   - editingUnitInPanning: Panning length to regard as editing unit.
        internal func setup(eventScrollView: EventScrollView) {
            self.eventScrollView = eventScrollView
        }

        internal func observe(cell: EventCell) {
            let cellRecognizers = cell.gestureRecognizers?.compactMap({ $0 as? UILongPressGestureRecognizer }) ?? []
            guard cellRecognizers.contains(where: { recognizer -> Bool in
                return addedLongPressGestureRecognizers.contains(recognizer)
            }) == false else { return }

            addedLongPressGestureRecognizers = addedLongPressGestureRecognizers.filter({ $0.view != cell })
            let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(eventCellDidLongPress))
            cell.addGestureRecognizer(recognizer)
            addedLongPressGestureRecognizers.append(recognizer)
        }

        internal func unobserve(cell: EventCell) {
            let cellRecognizers = cell.gestureRecognizers?.compactMap({ $0 as? UILongPressGestureRecognizer }) ?? []
            guard let recognizer = cellRecognizers.first(where: { recognizer in
                return addedLongPressGestureRecognizers.contains(recognizer)
            }) else { return }

            cell.removeGestureRecognizer(recognizer)
            addedLongPressGestureRecognizers = addedLongPressGestureRecognizers.filter({ $0.view != cell })
        }

        internal func beginEditing(for cell: EventCell) {
            guard let scrollView = eventScrollView else { return }

            heavyImpactFeedbackGenerator.prepare()
            lightImpactFeedbackGenerator.prepare()

            endEditing()
            editingCell = cell

            let snapshot = cell.snapshotView()
            snapshot.frame = cell.frame
            snapshot.alpha = 0.25
            scrollView.insertSubview(snapshot, belowSubview: cell)
            snapshotView = snapshot

            let overlayView = EditingOverlayView(cell: cell)
            overlayView.willPanHandler = { [weak self] _ in
                guard let self = self, let cell = self.editingCell else { return }
                self.eventAtBeginEditing = cell.event
                self.cellFrameAtBeginEditing = cell.frame
            }
            overlayView.didPanKnobHandler = { [weak self] panningPoint, length in
                guard let self = self else { return }
                self.edit(edge: panningPoint == .topKnob ? .top : .bottom, panningLength: length)
            }
            overlayView.didEndPanningHandler = { [weak self] _ in
                guard let self = self, let cell = self.editingCell else { return }
                self.eventAtBeginEditing = cell.event
                self.snapCellFrame()
                self.cellFrameAtBeginEditing = cell.frame
            }
            scrollView.addSubview(overlayView)
            editingOverlayView = overlayView

            state = .editing
            heavyImpactFeedbackGenerator.impactOccurred()
            didBeginEditingHandler?()
        }

        internal func endEditing() {
            editingCell = nil
            snapshotView?.removeFromSuperview()
            editingOverlayView?.removeFromSuperview()
            state = .ready
        }

        private func edit(edge: Edge, panningLength: CGFloat) {
            guard let layoutData = eventScrollView?.layoutData,
                let cell = editingCell,
                let eventAtBeginEditing = eventAtBeginEditing,
                let cellFrameAtBeginEditing = cellFrameAtBeginEditing,
                var newFrame = self.cellFrameAtBeginEditing
                else { return }
            let heightUnit = layoutData.layoutUnit.heightUnit
            var deltaHeight = panningLength
            let deltaHeightSign = deltaHeight != 0 ? deltaHeight / abs(deltaHeight) : 1

            switch edge {
            case .top:
                // if deltaHeight is negative, the frame will be expanded to top-side.
                // if deltaHeight is positive, the frame will be contracted to bottom-side.

                // Guard minimum height
                if newFrame.size.height - deltaHeight < heightUnit {
                    deltaHeight = deltaHeightSign * (newFrame.size.height - heightUnit)
                }
                newFrame.origin.y += deltaHeight
                newFrame.size.height -= deltaHeight

            case .bottom:
                // if the height is positive, the frame will be expanded to bottom-side.
                // if the height is negative, the frame will be contracted to top-side.

                // Guard minimum height
                if newFrame.size.height + deltaHeight < heightUnit {
                    deltaHeight = deltaHeightSign * (newFrame.size.height - heightUnit)
                }
                newFrame.size.height += deltaHeight

            case .both:
                break
            }
            cell.frame = newFrame
            
            //
            // Calc new Event start time
            //
            // positive: start time will be late.
            // negative: start time will be early.
            let deltaStartMinutes = layoutData.roundedMinutes(from: (newFrame.minY - cellFrameAtBeginEditing.minY))
            let totalMinutes = layoutData.roundedMinutes(from: newFrame.height)
            let newStartDate = eventAtBeginEditing.start.addingTimeInterval(TimeInterval(deltaStartMinutes * 60))
            let newEndDate = newStartDate.addingTimeInterval(TimeInterval(totalMinutes * 60))

            if cell.event.start != newStartDate || cell.event.end != newEndDate {
                var newEvent = cell.event
                newEvent.time = newStartDate ... newEndDate
                cell.configure(event: newEvent)

                lightImpactFeedbackGenerator.impactOccurred()
                didEditHandler?()
            }
        }
        
        private func snapCellFrame() {
            guard let layoutData = eventScrollView?.layoutData, let cell = editingCell else { return }
            let y = layoutData.roundedDistanceOfTimeRangeStart(to: cell.event.start)
            let height = layoutData.roundedHeight(from: cell.event.durationInSeconds)
            let snappedFrame = CGRect(x: cell.frame.minX,
                                      y: y,
                                      width: cell.frame.width,
                                      height: height)
            cell.frame = snappedFrame
        }

        @objc private func eventCellDidLongPress(_ sender: UILongPressGestureRecognizer) {
            guard let cell = sender.view as? EventCell else { return }
            let event = cell.event

            switch sender.state {
            case .began:
                if event.isEditable {
                    beginEditing(for: cell)
                } else {
                    errorFeedbackGenerator.notificationOccurred(.error)
                }

            default:
                editingCellDidPan(sender)
            }
        }

        @objc internal func editingCellDidPan(_ sender: UIGestureRecognizer) {
            guard let scrollView = eventScrollView else { return }
            guard let cell = sender.view as? EventCell else { return }
            let locationInContentSize = sender.location(in: scrollView)

            switch sender.state {
            case .began:
                firstTouchLocation = locationInContentSize
                lastTouchLocation = locationInContentSize

            case .changed:
                lastTouchLocation = locationInContentSize

            case .ended, .cancelled:
                lastTouchLocation = locationInContentSize

            default:
                break
            }
        }

        @objc private func eventCellWillRemoveFromSuperview(_ notification: Notification) {
            guard let cell = notification.object as? EventCell else { return }

            if cell == editingCell {
                endEditing()
            }

            unobserve(cell: cell)
        }
    }
}
