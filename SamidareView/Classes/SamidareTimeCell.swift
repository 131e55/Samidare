//
//  SamidareTimeCell.swift
//  SamidareView
//
//  Created by Keisuke Kawamura on 2018/03/25.
//

import UIKit

class SamidareTimeCell: UITableViewCell {

    private weak var timeView: UIView!
    private var timeViewWidthConstraint: NSLayoutConstraint!

    private(set) weak var timeLabel: UILabel!

    static var font = UIFont.systemFont(ofSize: 12)

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = .clear

        let timeView = UIView()
        timeView.backgroundColor = .groupTableViewBackground
        addSubview(timeView)
        timeView.translatesAutoresizingMaskIntoConstraints = false
        timeView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        timeView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        timeView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        timeViewWidthConstraint = timeView.widthAnchor.constraint(equalToConstant: 50)
        timeViewWidthConstraint.isActive = true

        let label = UILabel()
        label.font = SamidareTimeCell.font
        timeView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerXAnchor.constraint(equalTo: timeView.centerXAnchor).isActive = true
        label.topAnchor.constraint(equalTo: timeView.topAnchor).isActive = true
        timeLabel = label

        let lineView = UILabel()
        lineView.backgroundColor = .lightGray
        lineView.alpha = 0.5
        addSubview(lineView)
        lineView.translatesAutoresizingMaskIntoConstraints = false
        lineView.centerYAnchor.constraint(equalTo: timeLabel.centerYAnchor).isActive = true
        lineView.leadingAnchor.constraint(equalTo: timeView.trailingAnchor).isActive = true
        lineView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        lineView.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale).isActive = true
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(timeText: String, timeViewWidth: CGFloat = 50) {

        timeLabel.text = timeText
        timeViewWidthConstraint.constant = timeViewWidth
    }
}
