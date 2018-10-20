//
//  TimeScrollView.swift
//  Samidare
//
//  Created by Keisuke Kawamura on 2018/09/22.
//  Copyright (c) 2018 Keisuke Kawamura. All rights reserved.
//

import UIKit

open class TimeScrollView: UIScrollView {

    private var layoutData: LayoutDataStore.LayoutData!

    var didSetup: Bool {
        return layoutData != nil
    }

    private var mustCallInsertCells: Bool = false

    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }

    private func initialize() {
    }

    internal func setup(layoutData: LayoutDataStore.LayoutData) {
        self.layoutData = layoutData

        let contentHeight = CGFloat(layoutData.timeRange.numberOfIntervals) * layoutData.heightPerMinInterval
        contentSize = CGSize(width: bounds.width, height: contentHeight)

        mustCallInsertCells = true
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        contentSize = CGSize(width: bounds.width, height: contentSize.height)

        if mustCallInsertCells {
            insertCells()
        }
    }

    private func insertCells() {
        let timeRange = layoutData.timeRange
        let start = timeRange.start
        let end = timeRange.end
        let minInterval = timeRange.minInterval
        let numberOfRows = end.ceiled.hours - start.floored.hours + 1
        var nextCellPositionY: CGFloat = 0

        for row in 0 ..< numberOfRows {
            let timeText: String
            let height: CGFloat

            switch row {
            case 0:
                timeText = start.formattedString
                let numberOfIntervals = (60 - start.minutes) / minInterval
                height = CGFloat(numberOfIntervals) * layoutData.heightPerMinInterval

            case numberOfRows - 2:
                timeText = end.floored.formattedString
                let numberOfIntervals = end.minutes / minInterval
                height = CGFloat(numberOfIntervals) * layoutData.heightPerMinInterval

            case numberOfRows - 1:
                timeText = end.formattedString
                height = TimeCell.preferredFont.lineHeight

            default:
                timeText = Time(hours: start.hours + row, minutes: 0).formattedString
                let numberOfIntervals = 60 / timeRange.minInterval
                height = CGFloat(numberOfIntervals) * layoutData.heightPerMinInterval
            }

            let cell = TimeCell(timeText: timeText, timeViewWidth: layoutData.widthOfTimeColumn)
            cell.autoresizingMask = .flexibleWidth
            cell.frame = CGRect(x: 0, y: nextCellPositionY, width: 44, height: height)
            addSubview(cell)

            nextCellPositionY += height
        }

        mustCallInsertCells = false
    }
}
