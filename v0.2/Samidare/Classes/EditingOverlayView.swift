//
//  EditingOverlayView.swift
//  Samidare
//
//  Created by Keisuke Kawamura on 2018/10/27.
//

import UIKit

internal class EditingOverlayView: UIView {

    private static let nib: UINib = UINib(nibName: "EditingOverlayView", bundle: Bundle(for: EditingOverlayView.self))
    private weak var widthConstraint: NSLayoutConstraint!
    private weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var cellWidthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var cellHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var timeView: UIView!

    init() {
        super.init(frame: .zero)
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
}
