//
//  TimeScrollView.swift
//  Samidare
//
//  Created by Keisuke Kawamura on 2018/09/22.
//  Copyright (c) 2018 Keisuke Kawamura. All rights reserved.
//

import UIKit

open class TimeScrollView: UIScrollView {

    private var layoutData: LayoutData!

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

    internal func setup(layoutData: LayoutData) {
        self.layoutData = layoutData
        let ceiledNumberOfUnits = Int(ceil(
            Float(layoutData.timeRange.roundedDurationInMinutes) / Float(layoutData.unit.displayMinute)
        ))
        let contentHeight = CGFloat(ceiledNumberOfUnits) * layoutData.unit.displayHeight
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
        let calendar = Calendar.current
        let timeRange = layoutData.timeRange
        let minuteUnit = layoutData.unit.displayMinute
        let heightUnit = layoutData.unit.displayHeight
        let start = timeRange.lowerBound
        let end = timeRange.upperBound
        let startMinute = calendar.dateComponents([.minute], from: start).minute!
        let endMinute = calendar.dateComponents([.minute], from: end).minute!
        let existStartMinute = startMinute != 0
        let existEndMinute = endMinute != 0
        let flooredStart = calendar.date(from: calendar.dateComponents([.year, .month, .day, .hour], from: start))!
        let ceiledStart = existStartMinute ? flooredStart.addingTimeInterval(3600) : flooredStart
        let flooredEnd = calendar.date(from: calendar.dateComponents([.year, .month, .day, .hour], from: end))!
        // ex.) 00:00 - 02:00 => 00:00, 01:00, 02:00 => 3 rows
        // ex.) 00:30 - 02:00 => 00:30, 01:00, 02:00 => 3 rows
        // ex.) 00:30 - 02:30 => 00:30, 01:00, 02:00, 02:30 => 4 rows
        let numberOfRows = (existStartMinute ? 1 : 0)
                           + (ceiledStart ... flooredEnd).durationInSeconds / 3600 + 1
                           + (existEndMinute ? 1 : 0)

        var nextCellPositionY: CGFloat = 0

        for row in 0 ..< numberOfRows {
            let timeText: String
            let height: CGFloat

            switch row {
            case 0:
                timeText = TimeText(date: timeRange.lowerBound).body
                let numberOfUnits = (60 - startMinute) / minuteUnit
                height = CGFloat(numberOfUnits) * heightUnit

            case numberOfRows - 2:
                timeText = TimeText(date: flooredEnd).body
                let numberOfUnits = (60 - endMinute) / minuteUnit
                height = CGFloat(numberOfUnits) * heightUnit

            case numberOfRows - 1:
                timeText = TimeText(date: end).body
                height = TimeCell.preferredFont.lineHeight

            default:
                let date = calendar.date(byAdding: .hour, value: row, to: flooredStart)!
                timeText = TimeText(date: date).body
                let numberOfUnits = 60 / minuteUnit
                height = CGFloat(numberOfUnits) * heightUnit
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
