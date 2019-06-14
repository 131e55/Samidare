//
//  LayoutDataStore.swift
//  Samidare
//
//  Created by Keisuke Kawamura on 2018/09/22.
//  Copyright (c) 2018 Keisuke Kawamura. All rights reserved.
//

import UIKit

final internal class LayoutDataStore {

    struct LayoutData {
        let timeRange: TimeRange
        let heightPerMinInterval: CGFloat
        let indexPaths: [IndexPath]
        let xPositionOfColumn: [IndexPath: CGFloat]
        let widthOfColumn: [IndexPath: CGFloat]
        let totalWidthOfColumns: CGFloat
        let widthOfTimeColumn: CGFloat
        let columnSpacing: CGFloat
        
        /// Translate height to minutes by LayoutData.
        func roundedMinutes(from height: CGFloat) -> Int {
            let numberOfIntervals = Int(round(height / heightPerMinInterval))
            let minutes = numberOfIntervals * timeRange.minInterval
            return minutes
        }
        
        /// Translate time to frame.minY by LayoutData.
        func frameMinY(from time: Time) -> CGFloat {
            let numberOfIntervals = (time.totalMinutes - timeRange.start.totalMinutes) / timeRange.minInterval
            let y = CGFloat(numberOfIntervals) * heightPerMinInterval
            return y
        }
        
        /// Translate time range to height by LayoutData.
        func height(from times: ClosedRange<Time>) -> CGFloat {
            let numberOfIntervals = max((times.upperBound.totalMinutes - times.lowerBound.totalMinutes) / timeRange.minInterval, 1)
            let height = CGFloat(numberOfIntervals) * heightPerMinInterval
            return height
        }
    }

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
            heightPerMinInterval: dataSource.heightPerMinInterval(in: samidareView),
            indexPaths: indexPaths,
            xPositionOfColumn: xPositionOfColumn,
            widthOfColumn: widthOfColumn,
            totalWidthOfColumns: totalWidthOfColumns,
            widthOfTimeColumn: dataSource.widthOfTimeColumn(in: samidareView),
            columnSpacing: columnSpacing
        )
    }
}
