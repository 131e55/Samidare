//
//  TimeInformationRowView.swift
//  SamidareView
//
//  Created by Keisuke Kawamura on 2018/04/11.
//

import UIKit

class TimeInformationCell: UIView {

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
        let view = Bundle(for: myType).loadNibNamed("\(myType)", owner: self, options: nil)!.first as! UIView
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.topAnchor.constraint(equalTo: topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        view.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true

        timeViewWidthConstraint.constant = timeViewWidth

        timeLabel.font = myType.preferredFont
        timeLabel.text = timeText
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

}
