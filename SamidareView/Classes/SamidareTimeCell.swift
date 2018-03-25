//
//  SamidareTimeCell.swift
//  SamidareView
//
//  Created by Keisuke Kawamura on 2018/03/25.
//

import UIKit

class SamidareTimeCell: UITableViewCell {

    private(set) weak var timeLabel: UILabel!

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        timeLabel = label
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
