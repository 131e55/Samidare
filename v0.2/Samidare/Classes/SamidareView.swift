//
//  SamidareView.swift
//  Samidare
//
//  Created by Keisuke Kawamura on 2018/03/26.
//  Copyright (c) 2018 Keisuke Kawamura. All rights reserved.
//

import UIKit

open class SamidareView: UIView {

    public weak var dataSource: SamidareViewDataSource? {
        didSet {
            print("dataSource not nil")
            needsReloadData = true
            setNeedsLayout()
        }
    }
    private let dataSourceCache = SamidareViewDataSourceCache()
    private let eventScrollView = UIScrollView()
    private let timeScrollView = TimeScrollView()

    private var needsReloadData = true

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        print("SamidareView setup")
        eventScrollView.frame = bounds
        eventScrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(eventScrollView)

        timeScrollView.frame = bounds
        timeScrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(timeScrollView)

        eventScrollView.backgroundColor = UIColor.red.withAlphaComponent(0.3)
        timeScrollView.backgroundColor = UIColor.green.withAlphaComponent(0.3)
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        reloadDataIfNeeded()
        print("SamidareView layoutSubviews", needsReloadData)

        
    }

    public func reloadData() {
        print("SamidareView reloadData")

        dataSourceCache.clear()
        guard let dataSource = dataSource else {
            fatalError("SamidareViewDataSource not implemented")
        }
        dataSourceCache.store(
            timeRange: dataSource.timeRange(in: self),
            heightPerMinInterval: dataSource.heightPerMinInterval(in: self),
            widthOfTimeColumn: dataSource.widthOfTimeColumn(in: self)
        )

        needsReloadData = false
        setNeedsLayout()
    }

    func reloadDataIfNeeded() {
        if needsReloadData {
            reloadData()
        }
    }

    private func layoutScrollView() {

    }
}
