//
//  EventView.swift
//  SamidareView
//
//  Created by Keisuke Kawamura on 2018/03/26.
//

import UIKit

open class EventView: UIView {

    public var themeColor: UIColor = .cyan {
        didSet {
            backgroundColor = themeColor
        }
    }
    public var textColor: UIColor = .black {
        didSet {
            titleLabel.textColor = textColor
        }
    }

    private(set) var event: Event!
    private(set) weak var titleLabel: UILabel!

    public init(event: Event) {

        super.init(frame: .zero)

        self.event = event

        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 13)
        titleLabel.textAlignment = .center
        titleLabel.text = event.title
        titleLabel.textColor = textColor
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        self.titleLabel = titleLabel
    }

    required public init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
