//
//  TimeInformationRowView.swift
//  SamidareView
//
//  Created by Keisuke Kawamura on 2018/04/11.
//

import UIKit

class TimeInformationCell: UIView {

    static var nib: UINib!
    static let preferredFont = UIFont.systemFont(ofSize: 12)

    @IBOutlet private(set) weak var timeView: UIView!
    @IBOutlet private weak var timeLabel: UILabel!
    @IBOutlet private weak var timeViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var separatorHeightConstraint: NSLayoutConstraint! {
        didSet { separatorHeightConstraint.constant = 1 / UIScreen.main.scale }
    }

    public init(timeText: String, timeViewWidth: CGFloat = 50) {

        super.init(frame: .zero)

        let myType = type(of: self)
        if myType.nib == nil { myType.nib = UINib(nibName: "\(myType)", bundle: Bundle(for: myType)) }
        let view = myType.nib.instantiate(withOwner: self, options: nil).first as! UIView
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: topAnchor),
            view.bottomAnchor.constraint(equalTo: bottomAnchor),
            view.leadingAnchor.constraint(equalTo: leadingAnchor),
            view.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        timeViewWidthConstraint.constant = timeViewWidth

        timeLabel.font = myType.preferredFont
        timeLabel.text = timeText
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
