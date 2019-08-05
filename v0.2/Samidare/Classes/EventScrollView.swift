//
//  EventScrollView.swift
//  Samidare
//
//  Created by Keisuke Kawamura on 2018/09/30.
//  Copyright (c) 2018 Keisuke Kawamura. All rights reserved.
//

import UIKit

internal class EventScrollView: UIScrollView {

    private(set) var layoutData: LayoutData!

    private(set) var addedCells: [IndexPath: [EventCell]] = [:]

    private let editor: Editor = Editor()
    private let creator: Creator = Creator()
    private let autoScroller: AutoScroller = AutoScroller()
    
    private weak var cellInCreating: EventCell?

    /// Tells editing has begun.
    internal var didBeginEditingHandler: ((_ cell: EventCell) -> Void)?
    internal var didEditHandler: ((_ cell: EventCell) -> Void)?

    internal var didUpdateCreatingEventHandler: ((_ cell: EventCell) -> Void)?
    
    internal override var delegate: UIScrollViewDelegate? {
        didSet {
            if let _ = delegate as? EventScrollView {}
            else { fatalError("Don't use delegate") }
        }
    }

    internal var didSetup: Bool {
        return layoutData != nil
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        didInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        didInit()
    }

    private func didInit() {
        delegate = self
    }

    internal func setup(layoutData: LayoutData) {
        self.layoutData = layoutData

        let totalSpacing = layoutData.columnSpacing * CGFloat(layoutData.widthOfColumn.keys.count - 1)
        let contentWidth = layoutData.totalWidthOfColumns + totalSpacing
        let contentHeight = layoutData.totalHeightForTimeRange
        contentSize = CGSize(width: contentWidth, height: contentHeight)

        editor.setup(eventScrollView: self)
        editor.didBeginEditingHandler = { [weak self] cell in
            guard let self = self else { return }
            self.didBeginEditingHandler?(cell)
            self.autoScroller.isEnabled = true
        }
        editor.didEditHandler = { [weak self] cell in
            guard let self = self else { return }
            if self.cellInCreating == cell {
                self.didUpdateCreatingEventHandler?(cell)
            } else {
                self.didEditHandler?(cell)
            }
        }
        autoScroller.setup(eventScrollView: self)
    }
    
    internal func setupCreator(willCreateEventHandler: @escaping CreatorWillCreateEventHandler) {
        creator.setup(
            eventScrollView: self,
            willCreateEventHandler: willCreateEventHandler,
            didCreateEventHandler: { [weak self] cell in
                guard let self = self else { return }
                self.cellInCreating = cell
                self.editor.beginEditing(for: cell, displaysOriginalCell: false)
            })
    }

    internal func insertCells(_ cells: [EventCell], at indexPath: IndexPath) {
        guard let x = layoutData.xPositionOfColumn[indexPath],
            let width = layoutData.widthOfColumn[indexPath] else { return }

        for cell in cells {
            let y = layoutData.roundedDistanceOfTimeRangeStart(to: cell.event.start)
            let height = layoutData.roundedHeight(from: cell.event.durationInSeconds)
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

extension EventScrollView: UIScrollViewDelegate {
    
    static let didScrollNotification: Notification.Name = .init("EventScrollViewDidScrollNotification")
    static let didEndScrollNotification: Notification.Name = .init("EventScrollViewDidEndScrollNotification")

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Cancel Creating
        if let cell = cellInCreating {
            let cellRange = cell.frame.minX ... cell.frame.maxX
            let scrollViewRange = scrollView.contentOffset.x ... scrollView.contentOffset.x + scrollView.frame.width
            if cellRange.overlaps(scrollViewRange) == false {
                cell.removeFromSuperview()
            }
        }
        
        NotificationCenter.default.post(
            Notification(name: EventScrollView.didScrollNotification, object: nil, userInfo: nil)
        )
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate == false {
            NotificationCenter.default.post(
                Notification(name: EventScrollView.didEndScrollNotification, object: nil, userInfo: nil)
            )
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        NotificationCenter.default.post(
            Notification(name: EventScrollView.didEndScrollNotification, object: nil, userInfo: nil)
        )
    }
}

//
// MARK: - Select
//

extension EventScrollView {

    @objc private func eventCellDidTap(_ sender: UITapGestureRecognizer) {
        // TODO:
    }
}
