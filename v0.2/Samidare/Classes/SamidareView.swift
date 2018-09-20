//
//  SamidareView.swift
//  Samidare
//
//  Created by Keisuke Kawamura on 2018/03/26.
//  Copyright (c) 2018 Keisuke Kawamura. All rights reserved.
//

import UIKit

open class SamidareView: UIView {

    public weak var dataSource: SamidareViewDataSource?

    private let eventScrollView = UIScrollView()
    private let timeScrollView = UIScrollView()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        eventScrollView.frame = bounds
        eventScrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(eventScrollView)

        timeScrollView.frame = bounds
        timeScrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(timeScrollView)

        eventScrollView.backgroundColor = UIColor.red.withAlphaComponent(0.3)
        timeScrollView.backgroundColor = UIColor.green.withAlphaComponent(0.3)
    }

    public func reloadData() {

    }
}
