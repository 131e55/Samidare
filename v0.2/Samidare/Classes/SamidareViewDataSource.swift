//
//  SamidareViewDataSource.swift
//  Samidare
//
//  Created by Keisuke Kawamura on 2018/09/20.
//  Copyright (c) 2018 Keisuke Kawamura. All rights reserved.
//

import UIKit

public protocol SamidareViewDataSource: class {
    func timeRange(in samidareView: SamidareView) -> ClosedRange<Date>
    func unit(in samidareView: SamidareView) -> LayoutUnit
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
    public func timeRange(in samidareView: SamidareView) -> ClosedRange<Date> {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: Date())
        let start = calendar.date(from: components)!
        let end = calendar.date(byAdding: .day, value: 1, to: start)!
        return start ... end
    }
    
    public func unit(in samidareView: SamidareView) -> LayoutUnit {
        return LayoutUnit(displayMinute: 15, displayHeight: 8, editingMinute: 10)
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
