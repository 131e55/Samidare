//
//  LayoutDataStore.swift
//  Samidare
//
//  Created by Keisuke Kawamura on 2018/09/22.
//  Copyright (c) 2018 Keisuke Kawamura. All rights reserved.
//

import UIKit

final internal class LayoutDataStore {
    
    var cachedEventScrollViewLayoutData: EventScrollViewLayoutData?
    var cachedFrozenEventScrollViewLayoutData: EventScrollViewLayoutData?
    var cachedTimeScrollViewLayoutData: TimeScrollViewLayoutData?

    func clear() {
        cachedEventScrollViewLayoutData = nil
        cachedFrozenEventScrollViewLayoutData = nil
        cachedTimeScrollViewLayoutData = nil
    }

    func store(dataSource: SamidareViewDataSource, for samidareView: SamidareView) {
        let timeRange = dataSource.timeRange(in: samidareView)
        let layoutUnit = dataSource.layoutUnit(in: samidareView)
        var indexPaths: [IndexPath] = []
        var xPositionOfColumn: [IndexPath: CGFloat] = [:]
        var widthOfColumn: [IndexPath: CGFloat] = [:]
        var totalWidthOfColumns: CGFloat = 0
        var totalSpacingOfColumns: CGFloat = 0
        let columnSpacing = dataSource.columnSpacing(in: samidareView)
        
        //
        // Make cachedEventScrollViewLayoutData
        //
        
        for section in 0 ..< dataSource.numberOfSections(in: samidareView) {
            for column in 0 ..< dataSource.numberOfColumns(in: section, in: samidareView) {
                let indexPath = IndexPath(column: column, section: section)
                let width = dataSource.widthOfColumn(at: indexPath, in: samidareView)
                indexPaths.append(indexPath)
                xPositionOfColumn[indexPath] = totalWidthOfColumns + totalSpacingOfColumns
                widthOfColumn[indexPath] = width
                totalWidthOfColumns += width
                totalSpacingOfColumns += columnSpacing
            }
        }
        
        cachedEventScrollViewLayoutData = EventScrollViewLayoutData(
            timeRange: timeRange,
            layoutUnit: layoutUnit,
            indexPaths: indexPaths,
            xPositionOfColumn: xPositionOfColumn,
            widthOfColumn: widthOfColumn,
            totalWidthOfColumns: totalWidthOfColumns,
            columnSpacing: columnSpacing,
            totalSpacingOfColumns: totalSpacingOfColumns
        )
        
        //
        // Make cachedFrozenEventScrollViewLayoutData
        //
        
        indexPaths = []
        xPositionOfColumn = [:]
        widthOfColumn = [:]
        totalWidthOfColumns = 0
        totalSpacingOfColumns = 0
        
        for column in 0 ..< dataSource.numberOfFrozenColumns(in: samidareView) {
            let indexPath = IndexPath(column: column, section: 0)
            let width = dataSource.widthOfFrozenColumn(at: indexPath, in: samidareView)
            indexPaths.append(indexPath)
            xPositionOfColumn[indexPath] = totalWidthOfColumns + totalSpacingOfColumns
            widthOfColumn[indexPath] = width
            totalWidthOfColumns += width
            totalSpacingOfColumns += columnSpacing
        }
        
        cachedFrozenEventScrollViewLayoutData = EventScrollViewLayoutData(
            timeRange: timeRange,
            layoutUnit: layoutUnit,
            indexPaths: indexPaths,
            xPositionOfColumn: xPositionOfColumn,
            widthOfColumn: widthOfColumn,
            totalWidthOfColumns: totalWidthOfColumns,
            columnSpacing: columnSpacing,
            totalSpacingOfColumns: totalSpacingOfColumns
        )
        
        //
        // Make cachedTimeScrollViewLayoutData
        //
        
        cachedTimeScrollViewLayoutData = TimeScrollViewLayoutData(
            timeRange: timeRange,
            layoutUnit: layoutUnit,
            widthOfColumn: dataSource.widthOfTimeColumn(in: samidareView)
        )
    }
}
