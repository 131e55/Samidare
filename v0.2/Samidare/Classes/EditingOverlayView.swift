//
//  EditingOverlayView.swift
//  Samidare
//
//  Created by Keisuke Kawamura on 2018/10/27.
//

import UIKit

internal class EditingOverlayView: TouchPassedView {

    private static let nib: UINib = UINib(nibName: "EditingOverlayView", bundle: Bundle(for: EditingOverlayView.self))
    private weak var widthConstraint: NSLayoutConstraint!
    private weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var cellWidthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var cellHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var cellOverlayView: UIView!
    @IBOutlet private weak var timeView: UIView!
    @IBOutlet private weak var topKnobView: UIView!
    @IBOutlet private weak var bottomKnobView: UIView!

    /// First touch location in referencing EventScrollView.
    /// It's reset each time any gesture recognized.
    private var firstTouchLocation: CGPoint!
    /// Last touch location in referencing EventScrollView.
    private var lastTouchLocation: CGPoint!

    /// Tells panning top-bottom knobs.
    internal var didPanCellHandler: (() -> Void)?
    /// Tells panning top-bottom knobs.
    internal var didPanKnobHandler: (() -> Void)?

    init() {
        super.init(frame: .zero)
        isUserInteractionEnabled = true
        translatesAutoresizingMaskIntoConstraints = false

        let view = type(of: self).nib.instantiate(withOwner: self, options: nil).first as! UIView
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)

        widthConstraint = widthAnchor.constraint(equalToConstant: 0)
        heightConstraint = heightAnchor.constraint(equalToConstant: 0)

        NSLayoutConstraint.activate([
            widthConstraint,
            heightConstraint,
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

    func updateEditingCellStatus(frame: CGRect) {
        cellWidthConstraint.constant = frame.width
        cellHeightConstraint.constant = frame.height
        sizeToFit()
    }

    override func sizeToFit() {
        let space: CGFloat = 8
        let width = cellWidthConstraint.constant
                    + cellWidthConstraint.constant * 2  // left + right
                    + space * 4                         // left * 2 + right * 2
        let height = cellHeightConstraint.constant
                     + space * 2                        // top + bottom
        widthConstraint.constant = width
        heightConstraint.constant = height
    }

    @objc private func didPanCellOverlayView(_ sender: UIPanGestureRecognizer) {
        let location = sender.location(in: self)

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
        let location = sender.location(in: self)

        switch sender.state {
        case .began:
            firstTouchLocation = location
            lastTouchLocation = location
            dprint("did pan knob view", location)

        case .changed:
            lastTouchLocation = location
            let length = firstTouchLocation.y - lastTouchLocation.y
            dprint("did pan knob view", location, length)
            updateEditingCellStatus(frame:
                CGRect(x: 0,
                       y: 0,
                       width: cellWidthConstraint.constant,
                       height: cellHeightConstraint.constant + length))

        case .ended, .cancelled:
            break

        default:
            break
        }
    }
}
