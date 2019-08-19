//
//  TimeCell.swift
//  Samidare
//
//  Created by Keisuke Kawamura on 2018/04/11.
//  Copyright (c) 2018 Keisuke Kawamura. All rights reserved.
//

import UIKit

internal class TimeCell: UIView {

    static let nib: UINib = UINib(nibName: "TimeCell", bundle: Bundle(for: TimeCell.self))
    static let preferredFont = UIFont.systemFont(ofSize: 10)

    @IBOutlet private(set) weak var timeView: UIView!
    @IBOutlet private weak var timeLabel: UILabel!
    @IBOutlet private weak var timeViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var separatorHeightConstraint: NSLayoutConstraint! {
        didSet { separatorHeightConstraint.constant = 1 / UIScreen.main.scale }
    }
    
    public init(timeText: String, timeViewWidth: CGFloat = 50) {
        super.init(frame: .zero)

        let myType = type(of: self)

        let view = myType.nib.instantiate(withOwner: self, options: nil).first as! UIView
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)

        timeViewWidthConstraint.constant = timeViewWidth

        timeLabel.font = myType.preferredFont
        timeLabel.text = timeText
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
