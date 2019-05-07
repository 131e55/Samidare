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
        private var editingUnitInPanning: CGFloat = 1 {
            didSet {
                if editingUnitInPanning < 1 { editingUnitInPanning = 1 }
            }
        }
        private let heavyImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
        private let lightImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        private let errorFeedbackGenerator = UINotificationFeedbackGenerator()
        private var addedLongPressGestureRecognizers: [UILongPressGestureRecognizer] = []

        private(set) var state: State = .ready

        private weak var editingCell: EventCell?
        /// Cell frame of each edit. `each edit` is defined `top knob panning`, `bottom knob panning`, `cell panning`.
        private var cellFrameOfEachEdit: CGRect?
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
        internal func setup(eventScrollView: EventScrollView, editingUnitInPanning: CGFloat) {
            self.eventScrollView = eventScrollView
            self.editingUnitInPanning = editingUnitInPanning
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
            overlayView.willPanKnobHandler = { [weak self] knob in
                guard let self = self, let cell = self.editingCell else { return }
                self.cellFrameOfEachEdit = cell.frame
            }
            overlayView.didPanKnobHandler = { [weak self] knob, length in
                guard let self = self else { return }
                self.edit(edge: knob == .top ? .top : .bottom, panningLength: length)
            }
            overlayView.didEndPanningKnobHandler = { [weak self] knob in
                guard let self = self, let cell = self.editingCell else { return }
                self.cellFrameOfEachEdit = cell.frame
            }
            scrollView.addSubview(overlayView)
            editingOverlayView = overlayView

//            cell.addGestureRecognizer(
//                UIPanGestureRecognizer(target: self, action: #selector(editingCellDidPan))
//            )

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
            guard let layoutData = eventScrollView?.layoutData else { return }
            guard let cell = editingCell else { return }
            guard var newFrame = cellFrameOfEachEdit else { return }
            var deltaHeight = heightMustBeEdited(panningLength: panningLength)
            let deltaHeightSign = deltaHeight != 0 ? deltaHeight / abs(deltaHeight) : 1

            switch edge {
            case .top:
                dprint(deltaHeight, newFrame.size.height - deltaHeight, editingUnitInPanning)
                // if the height is negative, the frame will be expanded to top-side.
                // if the height is positive, the frame will be contracted to bottom-side.
                if newFrame.size.height - deltaHeight < editingUnitInPanning {
                    deltaHeight = deltaHeightSign * (newFrame.size.height - editingUnitInPanning)
                    dprint(deltaHeight)
                }
                newFrame.origin.y += deltaHeight
                newFrame.size.height -= deltaHeight
            case .bottom:
                // if the height is positive, the frame will be expanded to bottom-side.
                // if the height is negative, the frame will be contracted to top-side.
                if newFrame.size.height + deltaHeight < editingUnitInPanning {
                    deltaHeight = deltaHeightSign * (newFrame.size.height - editingUnitInPanning)
                }
                newFrame.size.height += deltaHeight
            case .both:
                break
            }

            if cell.frame != newFrame {
                //
                // Calc new Event start time
                //
                let deltaInterval = (newFrame.minY - cell.frame.minY) / layoutData.heightPerMinInterval
                // positive: delay the start time.
                // negative: 
                let deltaStartMinutes = Int(deltaInterval * CGFloat(layoutData.timeRange.minInterval))
                dprint(deltaStartMinutes)
                cell.frame = newFrame
                lightImpactFeedbackGenerator.impactOccurred()
            }
        }

        @objc private func eventCellDidLongPress(_ sender: UILongPressGestureRecognizer) {
            guard let cell = sender.view as? EventCell, let event = cell.event else { return }

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
            guard let cell = sender.view as? EventCell, let event = cell.event else { return }
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

        private func heightMustBeEdited(panningLength: CGFloat) -> CGFloat {
            let numberOfUnits = Int(panningLength / editingUnitInPanning)
            return editingUnitInPanning * CGFloat(numberOfUnits)
        }
    }
}
