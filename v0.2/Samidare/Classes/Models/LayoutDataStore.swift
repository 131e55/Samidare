//
//  LayoutDataStore.swift
//  Samidare
//
//  Created by Keisuke Kawamura on 2018/09/22.
//  Copyright (c) 2018 Keisuke Kawamura. All rights reserved.
//

import UIKit

public struct LayoutUnit {
    public let displayMinute: Int
    public let displayHeight: CGFloat
    public let editingMinute: Int
}

internal struct LayoutData {

    let timeRange: ClosedRange<Date>
    let unit: LayoutUnit
    let indexPaths: [IndexPath]
    let xPositionOfColumn: [IndexPath: CGFloat]
    let widthOfColumn: [IndexPath: CGFloat]
    let totalWidthOfColumns: CGFloat
    let widthOfTimeColumn: CGFloat
    let columnSpacing: CGFloat
    
    /// Translate height to minutes by LayoutData.
    func roundedMinutes(from height: CGFloat) -> Int {
        let numberOfIntervals = Int(round(height / unit.displayHeight))
        let minutes = numberOfIntervals * unit.displayMinute
        return minutes
    }
    
    private func roundedMinutes(from seconds: Int) -> Int {
        let flooredMinutes = seconds / 60
        let remainingSeconds = seconds - flooredMinutes * 60
        let roundedMinutes = flooredMinutes + (remainingSeconds >= 30 ? 1 : 0)
        return roundedMinutes
    }
    
    /// Calculate frame.minY from Date and LayoutData.
    func frameMinY(from date: Date) -> CGFloat {
        let isPast = date < timeRange.lowerBound
        let range = isPast ? date ... timeRange.lowerBound
                           : timeRange.lowerBound ... date
        let numberOfUnits = range.roundedDurationInMinutes / unit.displayMinute
        let y = (isPast ? -1 : 1) * CGFloat(numberOfUnits) * unit.displayHeight
        return y
    }
    
    /// Calculate height from seconds and LayoutData.
    func height(from seconds: Int) -> CGFloat {
        let numberOfUnits = roundedMinutes(from: seconds) / unit.displayMinute
        let height = CGFloat(numberOfUnits) * unit.displayHeight
        return height
    }
}


final internal class LayoutDataStore {
    
    var cachedData: LayoutData?

    func clear() {
        cachedData = nil
    }

    func store(dataSource: SamidareViewDataSource, for samidareView: SamidareView) {
        var indexPaths: [IndexPath] = []
        var xPositionOfColumn: [IndexPath: CGFloat] = [:]
        var widthOfColumn: [IndexPath: CGFloat] = [:]
        var totalWidthOfColumns: CGFloat = 0
        let columnSpacing = dataSource.columnSpacing(in: samidareView)
        var totalSpacing: CGFloat = 0

        for section in 0 ..< dataSource.numberOfSections(in: samidareView) {
            for column in 0 ..< dataSource.numberOfColumns(in: section, in: samidareView) {
                let indexPath = IndexPath(column: column, section: section)
                let width = dataSource.widthOfColumn(at: indexPath, in: samidareView)
                indexPaths.append(indexPath)
                xPositionOfColumn[indexPath] = totalWidthOfColumns + totalSpacing
                widthOfColumn[indexPath] = width
                totalWidthOfColumns += width
                totalSpacing += columnSpacing
            }
        }

        cachedData = LayoutData(
            timeRange: dataSource.timeRange(in: samidareView),
            unit: dataSource.unit(in: samidareView),
            indexPaths: indexPaths,
            xPositionOfColumn: xPositionOfColumn,
            widthOfColumn: widthOfColumn,
            totalWidthOfColumns: totalWidthOfColumns,
            widthOfTimeColumn: dataSource.widthOfTimeColumn(in: samidareView),
            columnSpacing: columnSpacing
        )
    }
}
