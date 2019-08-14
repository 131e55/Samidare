//
//  SamidareView.swift
//  Samidare
//
//  Created by Keisuke Kawamura on 2018/03/26.
//  Copyright (c) 2018 Keisuke Kawamura. All rights reserved.
//

import UIKit

public class SamidareView: UIView {

    public weak var dataSource: SamidareViewDataSource? {
        didSet {
            mustCallReloadData = true
            setNeedsLayout()
        }
    }
    private let layoutDataStore = LayoutDataStore()
    private let survivorManager = SurvivorManager()
    private let reusableCellQueue = ReusableCellQueue()
    private let eventScrollView = EventScrollView()
    private let frozenEventScrollView = EventScrollView()
    private var frozenEventScrollViewWidthConstraint: NSLayoutConstraint!
    private var frozenEventScrollViewLeftConstraint: NSLayoutConstraint!

    private let timeScrollView = TimeScrollView()
    private let frozenColumnBackgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
    private var frozenColumnBackgroundViewWidthConstraint: NSLayoutConstraint!

    public var expansionRateOfSurvivorArea: CGFloat {
        get { return survivorManager.expansionRateOfSurvivorArea }
        set { survivorManager.expansionRateOfSurvivorArea = newValue }
    }
    
    public var didBeginEditingEventHandler: ((_ cell: EventCell) -> Void)?
    public var didEditEventHandler: ((_ cell: EventCell) -> Void)?
    
    /// If you want to use EventCreator, implement it.
    public var willCreateEventHandler: CreatorWillCreateEventHandler? {
        didSet {
            if let handler = willCreateEventHandler {
                dprint("call")
                eventScrollView.setupCreator(willCreateEventHandler: handler)
            }
        }
    }
    public var didUpdateCreatingEventHandler: ((_ cell: EventCell) -> Void)?

    private var mustCallReloadData = true

    public override init(frame: CGRect) {
        super.init(frame: frame)
        didInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        didInit()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func didInit() {
        let inset: CGFloat = round(TimeCell.preferredFont.lineHeight / 2)
        eventScrollView.autoresizesSubviews = false
        dprint(eventScrollView.contentOffset)
        eventScrollView.contentInset = UIEdgeInsets(top: inset, left: 0, bottom: inset, right: 0)
        dprint(eventScrollView.contentOffset)
        eventScrollView.didBeginEditingHandler = { [weak self] cell in
            self?.didBeginEditingEventHandler?(cell)
        }
        eventScrollView.didEditHandler = { [weak self] cell in
            self?.didEditEventHandler?(cell)
        }
        eventScrollView.didUpdateCreatingEventHandler = { [weak self] cell in
            self?.didUpdateCreatingEventHandler?(cell)
        }
        addSubview(eventScrollView)
        eventScrollView.activateFitFrameConstarintsToSuperview()
        NotificationCenter.default.addObserver(self, selector: #selector(eventScrollViewDidScroll),
                                               name: EventScrollView.didScrollNotification,
                                               object: eventScrollView)

        frozenColumnBackgroundView.isUserInteractionEnabled = false
        frozenColumnBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(frozenColumnBackgroundView)
        frozenColumnBackgroundViewWidthConstraint = frozenColumnBackgroundView.widthAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([
            frozenColumnBackgroundView.leftAnchor.constraint(equalTo: leftAnchor),
            frozenColumnBackgroundView.topAnchor.constraint(equalTo: topAnchor),
            frozenColumnBackgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),
            frozenColumnBackgroundViewWidthConstraint
        ])

        frozenEventScrollView.autoresizesSubviews = false
        frozenEventScrollView.showsVerticalScrollIndicator = false
        frozenEventScrollView.showsHorizontalScrollIndicator = false
        frozenEventScrollView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(frozenEventScrollView)
        frozenEventScrollViewLeftConstraint = frozenEventScrollView.leftAnchor.constraint(equalTo: leftAnchor)
        frozenEventScrollViewWidthConstraint = frozenEventScrollView.widthAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([
            frozenEventScrollViewLeftConstraint,
            frozenEventScrollView.topAnchor.constraint(equalTo: topAnchor),
            frozenEventScrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            frozenEventScrollViewWidthConstraint
        ])
        NotificationCenter.default.addObserver(self, selector: #selector(frozenEventScrollViewDidScroll),
                                               name: EventScrollView.didScrollNotification,
                                               object: frozenEventScrollView)
    
        timeScrollView.autoresizesSubviews = false
        timeScrollView.isUserInteractionEnabled = false
        timeScrollView.contentInset = UIEdgeInsets(top: inset, left: 0, bottom: inset, right: 0)
        addSubview(timeScrollView)
        timeScrollView.activateFitFrameConstarintsToSuperview()
    }

    public func reloadData() {
        dprint("SamidareView reloadData")
        layoutDataStore.clear()
        eventScrollView.removeAllAddedCells()
        frozenEventScrollView.removeAllAddedCells()
        guard let dataSource = dataSource else { return }
        layoutDataStore.store(dataSource: dataSource, for: self)
        let eventLayoutData = layoutDataStore.cachedEventScrollViewLayoutData!
        let timeLayoutData = layoutDataStore.cachedTimeScrollViewLayoutData!
        let frozenLayoutData = layoutDataStore.cachedFrozenEventScrollViewLayoutData!

        frozenColumnBackgroundViewWidthConstraint.constant = timeLayoutData.widthOfColumn
                                                             + frozenLayoutData.columnSpacing
                                                             + frozenLayoutData.totalWidthOfColumns
                                                             + frozenLayoutData.totalSpacingOfColumns

        // First, set contentInset before set contentSize(set it in setup()), otherwise contentOffset is not correct.
        eventScrollView.contentInset.left = frozenColumnBackgroundViewWidthConstraint.constant
                                            + eventLayoutData.columnSpacing
        eventScrollView.contentInset.right = eventLayoutData.columnSpacing
        eventScrollView.scrollIndicatorInsets.left = eventScrollView.contentInset.left
        eventScrollView.scrollIndicatorInsets.right = eventScrollView.contentInset.right
 
        frozenEventScrollViewLeftConstraint.constant = timeLayoutData.widthOfColumn
                                                       + frozenLayoutData.columnSpacing
        frozenEventScrollViewWidthConstraint.constant = frozenLayoutData.totalWidthOfColumns
                                                        + frozenLayoutData.totalSpacingOfColumns

        eventScrollView.setup(layoutData: eventLayoutData)
        survivorManager.setup(layoutData: eventLayoutData)
        frozenEventScrollView.setup(layoutData: frozenLayoutData)
        insertCellsIntoFrozenScrollView()
        timeScrollView.setup(layoutData: timeLayoutData)

        mustCallReloadData = false
        setNeedsLayout()
    }

    func reloadDataIfNeeded() {
        if mustCallReloadData {
            reloadData()
        }
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        reloadDataIfNeeded()
        survivorManager.resetSurvivorArea(of: eventScrollView)
        layoutEventScrollView()
        timeScrollView.contentOffset.y = eventScrollView.contentOffset.y
        frozenEventScrollView.contentOffset.y = eventScrollView.contentOffset.y
    }

    private func layoutEventScrollView() {
        guard let dataSource = dataSource else { return }

        let insertIndexPaths = Array(survivorManager.judgeResult.difference.birth).sorted()
        for indexPath in insertIndexPaths {
            let cells = dataSource.cells(at: indexPath, in: self)
            if cells.isEmpty == false {
                eventScrollView.insertCells(cells, at: indexPath)
            }
        }
        let removeIndexPaths = survivorManager.judgeResult.difference.death
        for indexPath in removeIndexPaths {
            for removedCell in eventScrollView.removeCells(at: indexPath) ?? [] {
                reusableCellQueue.enqueue(removedCell)
            }
        }

        survivorManager.resetSurvivorIndexPaths(survivorManager.judgeResult.survivors)
    }
    
    private func insertCellsIntoFrozenScrollView() {
        guard let dataSource = dataSource,
            let layoutData = layoutDataStore.cachedFrozenEventScrollViewLayoutData else { return }
        for indexPath in layoutData.indexPaths {
            let cells = dataSource.frozenCells(at: indexPath, in: self)
            if cells.isEmpty == false {
                frozenEventScrollView.insertCells(cells, at: indexPath)
                dprint(cells)
            }
        }
    }

    public func register(_ nib: UINib, forCellReuseIndentifier identifier: String) {
        reusableCellQueue.register(nib, forCellReuseIdentifier: identifier)
    }

    public func dequeueCell<T: EventCell>(withReuseIdentifier identifier: String) -> T {
        if let cell = reusableCellQueue.dequeue(withReuseIdentifier: identifier) {
            return cell as! T
        }
        return reusableCellQueue.create(withReuseIdentifier: identifier) as! T
    }
}

extension SamidareView {
    @objc private func eventScrollViewDidScroll(_ notification: Notification) {
        guard let scrollView = notification.object as? EventScrollView,
            scrollView == eventScrollView else { return }
        setNeedsLayout()
    }
    
    @objc private func frozenEventScrollViewDidScroll(_ notification: Notification) {
        guard let scrollView = notification.object as? EventScrollView,
            scrollView == frozenEventScrollView else { return }
        eventScrollView.contentOffset.y = frozenEventScrollView.contentOffset.y
        setNeedsLayout()
    }
}
