//
//  EventScrollView.swift
//  Samidare
//
//  Created by Keisuke Kawamura on 2018/09/30.
//  Copyright (c) 2018 Keisuke Kawamura. All rights reserved.
//

import UIKit

protocol EventScrollViewDelegate: UIScrollViewDelegate {

}

public class EventScrollView: UIScrollView {

    private var layoutData: LayoutDataStore.LayoutData!

    private(set) var addedCells: [IndexPath: [Cell]] = [:]

    var didSetup: Bool {
        return layoutData != nil
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }

    private func initialize() {

    }

    func setup(layoutData: LayoutDataStore.LayoutData) {
        self.layoutData = layoutData
    }

    internal func insertCells(_ cells: [Cell], at indexPath: IndexPath) {
        guard let x = layoutData.xPositionOfColumn[indexPath],
            let width = layoutData.widthOfColumn[indexPath] else { return }
        let minInterval = layoutData.timeRange.minInterval
        let heightPerMinInterval = layoutData.heightPerMinInterval

        for cell in cells {
            guard let event = cell.event else { continue }
            var numberOfIntervals = (event.start.totalMinutes - layoutData.timeRange.start.totalMinutes) / minInterval
            let y = CGFloat(numberOfIntervals) * heightPerMinInterval
            numberOfIntervals = max((event.end.totalMinutes - event.start.totalMinutes) / minInterval, 1)
            let height = CGFloat(numberOfIntervals) * heightPerMinInterval
            cell.frame = CGRect(x: x, y: y, width: width, height: height)
            cell.indexPath = indexPath
            addSubview(cell)

            if addedCells[indexPath] == nil {
                addedCells[indexPath] = [cell]
            } else {
                addedCells[indexPath]!.append(cell)
            }
            dprint("addCell")
        }
    }

    internal func removeCells(at indexPath: IndexPath) -> [Cell]? {
        let addedCellsAtIndexPath = addedCells.removeValue(forKey: indexPath)
        if let cells = addedCellsAtIndexPath {
            cells.forEach {
                $0.removeFromSuperview()
            }
            return cells
        }
        return nil
    }
}
