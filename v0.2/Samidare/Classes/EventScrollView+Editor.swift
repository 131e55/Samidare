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

        private(set) var state: State = .ready

        private weak var editingCell: EventCell?
        private weak var snapshotView: UIView?
        private weak var editingOverlayView: EditingOverlayView?

        ///
        private var location: CGPoint = .zero {
            didSet { dprint(location) }
        }

        init() {
            NotificationCenter.default.addObserver(self, selector: #selector(eventCellWillRemoveFromSuperview),
                                                   name: EventCell.willRemoveFromSuperviewNotification, object: nil)
        }
        deinit {
            NotificationCenter.default.removeObserver(self)
        }

        func setup(eventScrollView: EventScrollView) {
            self.eventScrollView = eventScrollView
        }

        func beginEditing(for cell: EventCell) {
            guard let scrollView = eventScrollView else { return }

            impactFeedbackGenerator.prepare()

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
        }

        func endEditing() {
            editingCell = nil
            snapshotView?.removeFromSuperview()
            editingOverlayView?.removeFromSuperview()
            state = .ready
        }

        @objc internal func editingCellDidPan(_ sender: UIGestureRecognizer) {
            guard let cell = sender.view as? EventCell, let event = cell.event else { return }

            switch sender.state {
            case .began:
                location = sender.location(in: eventScrollView)

            case .changed:
                location = sender.location(in: eventScrollView)

            case .ended, .cancelled:
                break

            default:
                break
            }
        }

        @objc private func eventCellWillRemoveFromSuperview(_ notification: Notification) {
            guard let cell = notification.object as? EventCell else { return }

            if cell == editingCell {
                endEditing()
            }
        }
    }
}
