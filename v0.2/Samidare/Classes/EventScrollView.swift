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

    private(set) var addedCells: [IndexPath: [EventCell]] = [:]

    private let editor: Editor = Editor()
    private let autoScroller: AutoScroller = AutoScroller()

    internal var didSetup: Bool {
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

    private func initialize() {}

    internal func setup(layoutData: LayoutDataStore.LayoutData) {
        self.layoutData = layoutData

        let totalSpacing = layoutData.columnSpacing * CGFloat(layoutData.widthOfColumn.keys.count - 1)
        let contentWidth = layoutData.totalWidthOfColumns + totalSpacing
        let contentHeight = CGFloat(layoutData.timeRange.numberOfIntervals) * layoutData.heightPerMinInterval
        contentSize = CGSize(width: contentWidth, height: contentHeight)

        editor.setup(eventScrollView: self, editingUnitInPanning: layoutData.heightPerMinInterval)
        editor.didBeginEditingHandler = { [weak self] in
            guard let self = self else { return }
            self.autoScroller.isEnabled = true
        }

        autoScroller.setup(eventScrollView: self)
    }

    internal func insertCells(_ cells: [EventCell], at indexPath: IndexPath) {
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

            cell.addGestureRecognizer(
                UITapGestureRecognizer(target: self, action: #selector(eventCellDidTap))
            )
            editor.observe(cell: cell)

            if addedCells[indexPath] == nil {
                addedCells[indexPath] = [cell]
            } else {
                addedCells[indexPath]!.append(cell)
            }
        }
    }

    internal func removeCells(at indexPath: IndexPath) -> [EventCell]? {
        let addedCellsAtIndexPath = addedCells.removeValue(forKey: indexPath)
        if let cells = addedCellsAtIndexPath {
            for cell in cells {
                editor.unobserve(cell: cell)
                for recognizer in cell.gestureRecognizers ?? [] {
                    cell.removeGestureRecognizer(recognizer)
                }
                cell.removeFromSuperview()
            }
            return cells
        }
        return nil
    }
}

//
// MARK: - Select
//

extension EventScrollView {

    @objc private func eventCellDidTap(_ sender: UITapGestureRecognizer) {
        guard let cell = sender.view as? EventCell, let event = cell.event else { return }
        // TODO:
    }
}
