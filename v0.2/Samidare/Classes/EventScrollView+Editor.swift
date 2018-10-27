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
        private weak var editingOverlayView: EditingOverlayView?

        ///
        private var location: CGPoint = .zero {
            didSet { dprint(location) }
        }

        func setup(eventScrollView: EventScrollView) {
            self.eventScrollView = eventScrollView
        }

        func beginEditing(for cell: EventCell) {
            guard let scrollView = eventScrollView else { return }

            impactFeedbackGenerator.prepare()

            let snapshot = cell.snapshot()
            snapshot.frame = cell.frame
            snapshot.alpha = 0.25
            scrollView.insertSubview(snapshot, belowSubview: cell)

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
    }
}
