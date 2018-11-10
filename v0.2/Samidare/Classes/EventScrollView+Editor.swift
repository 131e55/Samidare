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

        private weak var eventScrollView: EventScrollView?
        private let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
        private let errorFeedbackGenerator = UINotificationFeedbackGenerator()
        private var addedLongPressGestureRecognizers: [UILongPressGestureRecognizer] = []

        private(set) var state: State = .ready

        private weak var editingCell: EventCell?
        private weak var snapshotView: UIView?
        private weak var editingOverlayView: EditingOverlayView?

        /// First touch location in referencing EventScrollView.
        /// It's reset each time any gesture recognized.
        private var firstTouchLocation: CGPoint!
        /// Last touch location in referencing EventScrollView.
        private var lastTouchLocation: CGPoint!

        /// Tells editing has begun.
        internal var didBeginEditingHandler: (() -> Void)?

        init() {
            NotificationCenter.default.addObserver(self, selector: #selector(eventCellWillRemoveFromSuperview),
                                                   name: EventCell.willRemoveFromSuperviewNotification, object: nil)
        }
        deinit {
            NotificationCenter.default.removeObserver(self)
        }

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

            impactFeedbackGenerator.prepare()

            endEditing()
            editingCell = cell

            let snapshot = cell.snapshotView()
            snapshot.frame = cell.frame
            snapshot.alpha = 0.25
            scrollView.insertSubview(snapshot, belowSubview: cell)
            snapshotView = snapshot

            let overlayView = EditingOverlayView()
            scrollView.addSubview(overlayView)
            NSLayoutConstraint.activate([
                overlayView.centerXAnchor.constraint(equalTo: cell.centerXAnchor),
                overlayView.centerYAnchor.constraint(equalTo: cell.centerYAnchor)
            ])
            overlayView.updateEditingCellStatus(frame: cell.frame)
            editingOverlayView = overlayView

//            cell.addGestureRecognizer(
//                UIPanGestureRecognizer(target: self, action: #selector(editingCellDidPan))
//            )

            state = .editing
            impactFeedbackGenerator.impactOccurred()
            didBeginEditingHandler?()
        }

        internal func endEditing() {
            editingCell = nil
            snapshotView?.removeFromSuperview()
            editingOverlayView?.removeFromSuperview()
            state = .ready
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
    }
}
