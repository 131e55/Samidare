//
//  EditingOverlayView.swift
//  Samidare
//
//  Created by Keisuke Kawamura on 2018/10/27.
//

import UIKit

/// EditingOverlayView manages its own layout constraints by itself.
internal class EditingOverlayView: TouchPassedView {

    private static let nib: UINib = UINib(nibName: "EditingOverlayView", bundle: Bundle(for: EditingOverlayView.self))
    /// Apply the constraint after move to superview. Until then it is nil.
    private weak var topConstraint: NSLayoutConstraint!
    /// Apply the constraint after move to superview. Until then it is nil.
    private weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var cellWidthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var cellHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var cellOverlayView: UIView!
    @IBOutlet private weak var timeView: UIView!
    @IBOutlet private weak var topKnobView: UIView!
    @IBOutlet private weak var bottomKnobView: UIView!

    private var editingCell: EventCell!

    /// First touch location in referencing EventScrollView.
    /// It's reset each time any gesture recognized.
    private var firstTouchLocation: CGPoint!
    /// Last touch location in referencing EventScrollView.
    private var lastTouchLocation: CGPoint!

    /// TODO:
    internal var didPanCellHandler: (() -> Void)?
    /// Tells begin panning top-bottom knobs.
    internal var willPanKnobHandler: ((_ knob: Knob) -> Void)?
    /// Tells panned top-bottom knobs.
    internal var didPanKnobHandler: ((_ knob: Knob, _ length: CGFloat) -> Void)?
    /// Tells end panning top-bottom knobs.
    internal var didEndPanningKnobHandler: ((_ knob: Knob) -> Void)?

    /// - Parameter cell: Editing target EventCell
    init(cell: EventCell) {
        super.init(frame: .zero)

        editingCell = cell
        isUserInteractionEnabled = true
        translatesAutoresizingMaskIntoConstraints = false

        backgroundColor = UIColor.purple.withAlphaComponent(0.25)

        let view = type(of: self).nib.instantiate(withOwner: self, options: nil).first as! UIView
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)

        NSLayoutConstraint.activate([
            view.centerXAnchor.constraint(equalTo: centerXAnchor),
            view.centerYAnchor.constraint(equalTo: centerYAnchor),
            view.widthAnchor.constraint(equalTo: widthAnchor),
            view.heightAnchor.constraint(equalTo: heightAnchor)
        ])

        cellOverlayView.addGestureRecognizer(
            UIPanGestureRecognizer(target: self, action: #selector(didPanCellOverlayView))
        )
        topKnobView.addGestureRecognizer(
            UIPanGestureRecognizer(target: self, action: #selector(didPanKnobView))
        )
        bottomKnobView.addGestureRecognizer(
            UIPanGestureRecognizer(target: self, action: #selector(didPanKnobView))
        )
    }
    required public init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        if superview != nil {
            setupLayoutConstraints()
        }
    }

    private func setupLayoutConstraints() {
        guard superview != nil else { fatalError("Call in didMoveToSuperview.") }

        topConstraint = topAnchor.constraint(equalTo: editingCell.topAnchor,
                                             constant: -topKnobView.bounds.height / 2)
        bottomConstraint = bottomAnchor.constraint(equalTo: editingCell.bottomAnchor,
                                                   constant: bottomKnobView.bounds.height / 2)
        // for support left and right sides. 8 is one-side space.
        let additionalWidth = timeView.bounds.width * 2 + 8 * 2

        NSLayoutConstraint.activate([
            topConstraint,
            bottomConstraint,
            centerXAnchor.constraint(equalTo: editingCell.centerXAnchor),
            widthAnchor.constraint(equalTo: editingCell.widthAnchor, constant: additionalWidth),
            cellOverlayView.widthAnchor.constraint(equalTo: editingCell.widthAnchor),
            cellOverlayView.heightAnchor.constraint(equalTo: editingCell.heightAnchor)
        ])
    }

    @objc private func didPanCellOverlayView(_ sender: UIPanGestureRecognizer) {
        let location = sender.location(in: nil)

        switch sender.state {
        case .began:
            dprint("cell area pan", location)

        case .changed:
            dprint("cell area pan", location)

        case .ended, .cancelled:
            break

        default:
            break
        }
    }

    @objc private func didPanKnobView(_ sender: UIPanGestureRecognizer) {
        guard sender.view == topKnobView || sender.view == bottomKnobView else { fatalError() }
        let location = sender.location(in: nil)
        let knob: Knob = sender.view == topKnobView ? .top : .bottom

        switch sender.state {
        case .began:
            firstTouchLocation = location
            lastTouchLocation = location
            willPanKnobHandler?(knob)

        case .changed:
            lastTouchLocation = location
            let length = lastTouchLocation.y - firstTouchLocation.y
            didPanKnobHandler?(knob, length)

        default:
            didEndPanningKnobHandler?(knob)
        }
    }
}

extension EditingOverlayView {
    enum Knob {
        case top
        case bottom
    }
}
