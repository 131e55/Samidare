//
//  SamidareViewDataSource.swift
//  Samidare
//
//  Created by Keisuke Kawamura on 2018/09/20.
//  Copyright (c) 2018 Keisuke Kawamura. All rights reserved.
//

import UIKit

public protocol SamidareViewDataSource: class {
    func timeRange(in samidareView: SamidareView) -> TimeRange
    func numberOfSections(in samidareView: SamidareView) -> Int
    func numberOfColumns(in section: Int, in samidareView: SamidareView) -> Int
    func numberOfFrozenColumns(in samidareView: SamidareView) -> Int
    func cells(at indexPath: IndexPath, in samidareView: SamidareView) -> [EventCell]
    func widthOfColumn(at indexPath: IndexPath, in samidareView: SamidareView) -> CGFloat
    func widthOfTimeColumn(in samidareView: SamidareView) -> CGFloat
    func heightPerMinInterval(in samidareView: SamidareView) -> CGFloat
    func columnSpacing(in samidareView: SamidareView) -> CGFloat
}

extension SamidareViewDataSource {
    public func timeRange(in samidareView: SamidareView) -> TimeRange {
        return TimeRange(start: .zero, end: Time(hours: 24, minutes: 0), minInterval: 15)
    }
    public func numberOfFrozenColumns(in samidareView: SamidareView) -> Int {
        return 0
    }
    public func widthOfColumn(at indexPath: IndexPath, in samidareView: SamidareView) -> CGFloat {
        return 44
    }
    public func widthOfTimeColumn(in samidareView: SamidareView) -> CGFloat {
        return 40
    }
    public func heightPerMinInterval(in samidareView: SamidareView) -> CGFloat {
        return 8
    }
    public func columnSpacing(in samidareView: SamidareView) -> CGFloat {
        return 2
    }
}
