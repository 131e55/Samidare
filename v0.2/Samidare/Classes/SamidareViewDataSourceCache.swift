//
//  SamidareViewDataSourceCache.swift
//  Samidare
//
//  Created by Keisuke Kawamura on 2018/09/22.
//  Copyright (c) 2018 Keisuke Kawamura. All rights reserved.
//

internal class SamidareViewDataSourceCache {

    struct Data {
        let timeRange: TimeRange
        let heightPerMinInterval: CGFloat
        let widthOfTimeColumn: CGFloat
    }

    var cachedData: Data?

    func clear() {
        cachedData = nil
    }

    func store(timeRange: TimeRange, heightPerMinInterval: CGFloat, widthOfTimeColumn: CGFloat) {
        cachedData = Data(timeRange: timeRange,
                          heightPerMinInterval: heightPerMinInterval,
                          widthOfTimeColumn: widthOfTimeColumn)
    }
}
