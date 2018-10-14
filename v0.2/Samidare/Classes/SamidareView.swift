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
        get { return survivorManager.expansionRateOfSurvivorArea }
        set { survivorManager.expansionRateOfSurvivorArea = newValue }
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
        dprint("SamidareView initialize")
        eventScrollView.frame = bounds
        eventScrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        eventScrollView.delegate = self
        addSubview(eventScrollView)

        timeScrollView.frame = bounds
        timeScrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        timeScrollView.isUserInteractionEnabled = false
        addSubview(timeScrollView)
        timeScrollView.isHidden = true
    }

    public func reloadData() {
        dprint("SamidareView reloadData")
        layoutDataStore.clear()
        guard let dataSource = dataSource else { return }
        layoutDataStore.store(dataSource: dataSource, for: self)
        let layoutData = layoutDataStore.cachedData!

        resetScrollViewContentSize()
        survivorManager.setup(layoutData: layoutData)
        eventScrollView.setup(layoutData: layoutData)

        needsReloadData = false
        setNeedsLayout()
    }

    func reloadDataIfNeeded() {
        if needsReloadData {
            reloadData()
        }
    }

    private func resetScrollViewContentSize() {
        guard let layoutData = layoutDataStore.cachedData else { return }

        let contentHeight = CGFloat(layoutData.timeRange.numberOfIntervals) * layoutData.heightPerMinInterval
        eventScrollView.contentSize = CGSize(width: layoutData.totalWidthOfColumns, height: contentHeight)

        dprint(layoutData.timeRange.numberOfIntervals, "*", layoutData.heightPerMinInterval)
        dprint(eventScrollView.contentSize)
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        reloadDataIfNeeded()
        survivorManager.resetSurvivorArea(of: eventScrollView)
        layoutScrollView()
    }

    private func layoutScrollView() {
        guard let dataSource = dataSource else { return }

        dprint(survivorManager.judgeResult.difference.birth)

        let insertIndexPaths = Array(survivorManager.judgeResult.difference.birth).sorted()
        for indexPath in insertIndexPaths {
            let cells = dataSource.cells(at: indexPath, in: self)
            if !cells.isEmpty {
                eventScrollView.insertCells(cells, at: indexPath)
            }
        }
        let removeIndexPaths = survivorManager.judgeResult.difference.death
        for indexPath in removeIndexPaths {
            eventScrollView.removeCells(at: indexPath)
        }

        survivorManager.resetSurvivorIndexPaths(survivorManager.judgeResult.survivors)
    }

    public func dequeueCell<T: Cell>(withReuseIdentifier identifier: String, for indexPath: IndexPath) -> T {
        let cell = Cell()
        return cell as! T
    }
}

extension SamidareView: UIScrollViewDelegate {

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        setNeedsLayout()
    }
}
