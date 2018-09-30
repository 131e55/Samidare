//
//  SamidareView.swift
//  Samidare
//
//  Created by Keisuke Kawamura on 2018/03/26.
//  Copyright (c) 2018 Keisuke Kawamura. All rights reserved.
//

import UIKit

public class SamidareView: UIView {

    public weak var dataSource: SamidareViewDataSource? {
        didSet {
            needsReloadData = true
            setNeedsLayout()
        }
    }
    private let layoutDataStore = LayoutDataStore()
    private let survivorManager = SurvivorManager()
    private let eventScrollView = EventScrollView()
    private let timeScrollView = TimeScrollView()

    public var expansionRateOfSurvivorArea: CGFloat {
        get {
            return survivorManager.expansionRateOfSurvivorArea
        }
        set {
            survivorManager.expansionRateOfSurvivorArea = newValue
        }
    }

    private var needsReloadData = true

    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }

    private func initialize() {
        print("SamidareView initialize")
        eventScrollView.frame = bounds
        eventScrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        eventScrollView.delegate = self
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

        layoutEventScrollViewContentSize()
        survivorManager.resetSurvivorArea(of: eventScrollView)
    }

    public func reloadData() {
        print("SamidareView reloadData")
        layoutDataStore.clear()
        guard let dataSource = dataSource else { return }
        layoutDataStore.store(dataSource: dataSource, for: self)
        survivorManager.setup(layoutData: layoutDataStore.cachedData!)
        needsReloadData = false
        setNeedsLayout()
    }

    func reloadDataIfNeeded() {
        if needsReloadData {
            reloadData()
        }
    }

    private func layoutEventScrollViewContentSize() {
        guard let layoutDataStore = layoutDataStore.cachedData else { return }
        let contentHeight = CGFloat(layoutDataStore.timeRange.numberOfIntervals)
                            * layoutDataStore.heightPerMinInterval
        eventScrollView.contentSize = CGSize(width: layoutDataStore.totalWidthOfEventColumns,
                                             height: contentHeight)
        print(layoutDataStore.timeRange.numberOfIntervals, "*", layoutDataStore.heightPerMinInterval)
        print(eventScrollView.contentSize)
    }

    private func layoutEventScrollView() {
        guard let dataSource = dataSource else { return }


    }

}

extension SamidareView: UIScrollViewDelegate {

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        survivorManager.resetSurvivorArea(of: scrollView)
        survivorManager.judge()
    }
}
