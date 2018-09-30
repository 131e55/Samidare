//
//  LayoutDataStore.swift
//  Samidare
//
//  Created by Keisuke Kawamura on 2018/09/22.
//  Copyright (c) 2018 Keisuke Kawamura. All rights reserved.
//

import Foundation

internal class LayoutDataStore {

    struct LayoutData {
        let timeRange: TimeRange
        let heightPerMinInterval: CGFloat
        let widthOfEventColumn: [IndexPath: CGFloat]
        let totalWidthOfEventColumns: CGFloat
        let widthOfTimeColumn: CGFloat
    }

    var cachedData: LayoutData?

    func clear() {
        cachedData = nil
    }

    func store(dataSource: SamidareViewDataSource, for samidareView: SamidareView) {

        var totalWidthOfEventColumns: CGFloat = 0
        var widthOfEventColumn: [IndexPath: CGFloat] = [:]
        for section in 0 ..< dataSource.numberOfSections(in: samidareView) {
            for column in 0 ..< dataSource.numberOfColumns(inSection: section, in: samidareView) {
                let indexPath = IndexPath(column: column, section: section)
                let width = dataSource.widthOfEventColumn(at: indexPath, in: samidareView)
                widthOfEventColumn[indexPath] = width
                totalWidthOfEventColumns += width
            }
        }

        cachedData = LayoutData(
            timeRange: dataSource.timeRange(in: samidareView),
            heightPerMinInterval: dataSource.heightPerMinInterval(in: samidareView),
            widthOfEventColumn: widthOfEventColumn,
            totalWidthOfEventColumns: totalWidthOfEventColumns,
            widthOfTimeColumn: dataSource.widthOfTimeColumn(in: samidareView)
        )
    }
}
