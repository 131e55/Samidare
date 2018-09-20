//
//  SamidareViewDataSource.swift
//  Samidare
//
//  Created by Keisuke Kawamura on 2018/09/20.
//  Copyright (c) 2018 Keisuke Kawamura. All rights reserved.
//

import Foundation


public protocol SamidareViewDataSource: class {
    func timeRange(in samidareView: SamidareView) -> TimeRange
    func numberOfSections(in samidareView: SamidareView) -> Int
    func numberOfColumns(inSection: Int, in samidareView: SamidareView) -> Int
    func cells(at indexPath: IndexPath, in samidareView: SamidareView) -> [Cell]
    func width(at indexPath: IndexPath, in samidareView: SamidareView) -> CGFloat
    func timeColumnWidth(in samidareView: SamidareView) -> CGFloat
}

extension SamidareViewDataSource {
    public func timeRange(in samidareView: SamidareView) -> TimeRange {
        return TimeRange(start: .zero, end: Time(hours: 24, minutes: 0), minInterval: 15)
    }
    public func width(at indexPath: IndexPath, in samidareView: SamidareView) -> CGFloat {
        return 44
    }
    public func timeColumnWidth(in samidareView: SamidareView) -> CGFloat {
        return 44
    }
}
