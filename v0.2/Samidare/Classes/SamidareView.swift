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
    private let timeScrollView = TimeScrollView()
//    private let frozenEventScrollView = UIScrollView()
    private let eventScrollView = UIScrollView()


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
        timeScrollView.isUserInteractionEnabled = false
        addSubview(timeScrollView)

        eventScrollView.backgroundColor = UIColor.red.withAlphaComponent(0.3)
        timeScrollView.backgroundColor = UIColor.green.withAlphaComponent(0.3)
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        reloadDataIfNeeded()
        print("SamidareView layoutSubviews", needsReloadData)

        layoutEventScrollView()
    }

    public func reloadData() {
        print("SamidareView reloadData")

        dataSourceCache.clear()
        guard let dataSource = dataSource else {
            fatalError("SamidareViewDataSource not implemented")
        }

        var totalWidthOfEventColumns: CGFloat = 0
        var widthOfEventColumn: [IndexPath: CGFloat] = [:]
        for section in 0 ..< dataSource.numberOfSections(in: self) {
            for column in 0 ..< dataSource.numberOfColumns(inSection: section, in: self) {
                let indexPath = IndexPath(column: column, section: section)
                let width = dataSource.widthOfEventColumn(at: indexPath, in: self)
                widthOfEventColumn[indexPath] = width
                totalWidthOfEventColumns += width
            }
        }

        dataSourceCache.store(
            timeRange: dataSource.timeRange(in: self),
            heightPerMinInterval: dataSource.heightPerMinInterval(in: self),
            widthOfEventColumn: widthOfEventColumn,
            totalWidthOfEventColumns: totalWidthOfEventColumns,
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

    private func layoutEventScrollView() {
        guard let dataSource = dataSourceCache.cachedData else { return }

        let contentHeight = CGFloat(dataSource.timeRange.numberOfIntervals) * dataSource.heightPerMinInterval
        eventScrollView.contentSize = CGSize(width: dataSource.totalWidthOfEventColumns,
                                             height: contentHeight)
        print(dataSource.timeRange.numberOfIntervals, "*", dataSource.heightPerMinInterval)
        print(eventScrollView.contentSize)

        
    }
}
