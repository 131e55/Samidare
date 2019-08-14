//
//  SamidareViewDataSource.swift
//  Samidare
//
//  Created by Keisuke Kawamura on 2018/09/20.
//  Copyright (c) 2018 Keisuke Kawamura. All rights reserved.
//

import UIKit

public protocol SamidareViewDataSource: class {
    // Shared
    func timeRange(in samidareView: SamidareView) -> ClosedRange<Date>
    func layoutUnit(in samidareView: SamidareView) -> LayoutUnit
    func columnSpacing(in samidareView: SamidareView) -> CGFloat
    // EventScrollView
    func numberOfSections(in samidareView: SamidareView) -> Int
    func numberOfColumns(in section: Int, in samidareView: SamidareView) -> Int
    func widthOfColumn(at indexPath: IndexPath, in samidareView: SamidareView) -> CGFloat
    func cells(at indexPath: IndexPath, in samidareView: SamidareView) -> [EventCell]
    // EventScrollView(frozen)
    func numberOfFrozenColumns(in samidareView: SamidareView) -> Int
    func widthOfFrozenColumn(at indexPath: IndexPath, in samidareView: SamidareView) -> CGFloat
    func frozenCells(at indexPath: IndexPath, in samidareView: SamidareView) -> [EventCell]
    // TimeScrollView
    func widthOfTimeColumn(in samidareView: SamidareView) -> CGFloat
    // TitleScrollView
    func heightOfColumnTitle(in samidareView: SamidareView) -> CGFloat
    func titleViewOfTimeColumn(in samidareView: SamidareView) -> UIView?
    func titleViewOfFrozenColumn(at indexPath: IndexPath, in samidareView: SamidareView) -> UIView?
    func titleCellOfEventColumn(at indexPath: IndexPath, in samidareView: SamidareView) -> UICollectionViewCell?
}

extension SamidareViewDataSource {
    public func timeRange(in samidareView: SamidareView) -> ClosedRange<Date> {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: Date())
        let start = calendar.date(from: components)!
        let end = calendar.date(byAdding: .day, value: 1, to: start)!
        return start ... end
    }
    public func layoutUnit(in samidareView: SamidareView) -> LayoutUnit {
        return LayoutUnit(minuteUnit: 15, heightUnit: 8, initialMinutesInCreating: 60)
    }
    public func columnSpacing(in samidareView: SamidareView) -> CGFloat {
        return 2
    }

    public func widthOfColumn(at indexPath: IndexPath, in samidareView: SamidareView) -> CGFloat {
        return 44
    }
    
    public func numberOfFrozenColumns(in samidareView: SamidareView) -> Int {
        return 0
    }
    public func widthOfFrozenColumn(at indexPath: IndexPath, in samidareView: SamidareView) -> CGFloat {
        return 44
    }
    public func frozenCells(at indexPath: IndexPath, in samidareView: SamidareView) -> [EventCell] {
        return []
    }

    public func widthOfTimeColumn(in samidareView: SamidareView) -> CGFloat {
        return 40
    }

    public func heightOfColumnTitle(in samidareView: SamidareView) -> CGFloat {
        return 0
    }
    public func titleViewOfTimeColumn(in samidareView: SamidareView) -> UIView? {
        return nil
    }
    public func titleViewOfFrozenColumn(at indexPath: IndexPath, in samidareView: SamidareView) -> UIView? {
        return nil
    }
    public func titleCellOfEventColumn(at indexPath: IndexPath, in samidareView: SamidareView) -> UICollectionViewCell? {
        return nil
    }
}
