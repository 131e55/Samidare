//
//  LayoutDataStore.swift
//  Samidare
//
//  Created by Keisuke Kawamura on 2018/09/22.
//  Copyright (c) 2018 Keisuke Kawamura. All rights reserved.
//

import Foundation

extension SamidareView {
final internal class LayoutDataStore {

    struct LayoutData {
        let timeRange: TimeRange
        let heightPerMinInterval: CGFloat
        let indexPaths: [IndexPath]
        let xPositionOfEventColumn: [IndexPath: CGFloat]
        let widthOfEventColumn: [IndexPath: CGFloat]
        let totalWidthOfEventColumns: CGFloat
        let widthOfTimeColumn: CGFloat
    }

    var cachedData: LayoutData?

    func clear() {
        cachedData = nil
    }

    func store(dataSource: SamidareViewDataSource, for samidareView: SamidareView) {

        var indexPaths: [IndexPath] = []
        var xPositionOfEventColumn: [IndexPath: CGFloat] = [:]
        var widthOfEventColumn: [IndexPath: CGFloat] = [:]
        var totalWidthOfEventColumns: CGFloat = 0
        for section in 0 ..< dataSource.numberOfSections(in: samidareView) {
            for column in 0 ..< dataSource.numberOfColumns(inSection: section, in: samidareView) {
                let indexPath = IndexPath(column: column, section: section)
                let width = dataSource.widthOfEventColumn(at: indexPath, in: samidareView)
                indexPaths.append(indexPath)
                xPositionOfEventColumn[indexPath] = totalWidthOfEventColumns
                widthOfEventColumn[indexPath] = width
                totalWidthOfEventColumns += width
            }
        }

        cachedData = LayoutData(
            timeRange: dataSource.timeRange(in: samidareView),
            heightPerMinInterval: dataSource.heightPerMinInterval(in: samidareView),
            indexPaths: indexPaths,
            xPositionOfEventColumn: xPositionOfEventColumn,
            widthOfEventColumn: widthOfEventColumn,
            totalWidthOfEventColumns: totalWidthOfEventColumns,
            widthOfTimeColumn: dataSource.widthOfTimeColumn(in: samidareView)
        )
    }
}
}
