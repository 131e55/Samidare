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
    private let layoutDataStore: LayoutDataStore = LayoutDataStore()
    private let survivorManager: SurvivorManager = SurvivorManager()
    private let reusableCellQueue: ReusableCellQueue = ReusableCellQueue()

    private let frozenRowView: UIView = UIView()
    private var frozenRowViewHeightConstraint: NSLayoutConstraint!
    private let frozenTopLeftBackgroundView: UIVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
    private var frozenTopLeftBackgroundViewWidthConstraint: NSLayoutConstraint!
    private let frozenRowBackgroundView: UIVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
    private let frozenColumnTitleViewContainer: UIView = UIView()
    private var frozenColumnTitleViewContainerWidthConstraint: NSLayoutConstraint!
    private let eventTitleCollectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    private let frozenColumnBackgroundView: UIVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
    private var frozenColumnBackgroundViewTopConstraint: NSLayoutConstraint!
    private var frozenColumnBackgroundViewWidthConstraint: NSLayoutConstraint!
    
    private let eventScrollView: EventScrollView = EventScrollView()
    private let timeScrollView: TimeScrollView = TimeScrollView()
    private let frozenEventScrollView: EventScrollView = EventScrollView()
    private var frozenEventScrollViewWidthConstraint: NSLayoutConstraint!
    private var frozenEventScrollViewLeftConstraint: NSLayoutConstraint!

    public var additionalContentInset: UIEdgeInsets?
    public var expansionRateOfSurvivorArea: CGFloat {
        get { return survivorManager.expansionRateOfSurvivorArea }
        set { survivorManager.expansionRateOfSurvivorArea = newValue }
    }

    public var cellWasTappedHandler: ((_ cell: EventCell) -> Void)?

    public var didBeginEditingEventHandler: ((_ cell: EventCell) -> Void)?
    public var didEditEventHandler: ((_ cell: EventCell) -> Void)?
    public var didEndEditingEventHandler: ((_ cell: EventCell) -> Void)?
    
    /// If you want to use EventCreator, implement it.
    public var willCreateEventHandler: CreatorWillCreateEventHandler? {
        didSet {
            if let handler = willCreateEventHandler {
                eventScrollView.setupCreator(willCreateEventHandler: handler)
            }
        }
    }
    public var didUpdateCreatingEventHandler: ((_ cell: EventCell) -> Void)?

    public var isScrollEnabled: Bool = true {
        didSet {
            eventScrollView.isScrollEnabled = isScrollEnabled
            frozenEventScrollView.isScrollEnabled = isScrollEnabled
            timeScrollView.isScrollEnabled = isScrollEnabled
        }
    }
    
    public var contentSize: CGSize {
        return eventScrollView.contentSize
    }
    public var contentInset: UIEdgeInsets {
        return eventScrollView.contentInset
    }
    
    private var mustCallReloadData: Bool = true

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
        eventScrollView.autoresizesSubviews = false
        eventScrollView.cellWasTappedHandler = { [weak self] cell in
            self?.cellWasTappedHandler?(cell)
        }
        eventScrollView.didBeginEditingHandler = { [weak self] cell in
            self?.didBeginEditingEventHandler?(cell)
        }
        eventScrollView.didEditHandler = { [weak self] cell in
            self?.didEditEventHandler?(cell)
        }
        eventScrollView.didEndEditingEventHandler = { [weak self] cell in
            self?.didEndEditingEventHandler?(cell)
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
        frozenColumnBackgroundViewTopConstraint = frozenColumnBackgroundView.topAnchor.constraint(equalTo: topAnchor)
        frozenColumnBackgroundViewWidthConstraint = frozenColumnBackgroundView.widthAnchor.constraint(equalToConstant: 0)
        addSubview(frozenColumnBackgroundView)
        NSLayoutConstraint.activate([
            frozenColumnBackgroundView.leftAnchor.constraint(equalTo: leftAnchor),
            frozenColumnBackgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),
            frozenColumnBackgroundViewTopConstraint,
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
        addSubview(timeScrollView)
        timeScrollView.activateFitFrameConstarintsToSuperview()
        
        frozenRowView.isUserInteractionEnabled = false
        frozenRowView.translatesAutoresizingMaskIntoConstraints = false
        frozenRowViewHeightConstraint = frozenRowView.heightAnchor.constraint(equalToConstant: 0)
        addSubview(frozenRowView)
        NSLayoutConstraint.activate([
            frozenRowView.leftAnchor.constraint(equalTo: leftAnchor),
            frozenRowView.topAnchor.constraint(equalTo: topAnchor),
            frozenRowView.rightAnchor.constraint(equalTo: rightAnchor),
            frozenRowViewHeightConstraint
        ])
        
        frozenRowView.addSubview(frozenTopLeftBackgroundView)
        frozenTopLeftBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        frozenTopLeftBackgroundViewWidthConstraint = frozenTopLeftBackgroundView.widthAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([
            frozenTopLeftBackgroundView.leftAnchor.constraint(equalTo: frozenRowView.leftAnchor),
            frozenTopLeftBackgroundView.topAnchor.constraint(equalTo: frozenRowView.topAnchor),
            frozenTopLeftBackgroundView.bottomAnchor.constraint(equalTo: frozenRowView.bottomAnchor),
            frozenTopLeftBackgroundViewWidthConstraint
        ])

        frozenRowView.addSubview(frozenRowBackgroundView)
        frozenRowBackgroundView.isUserInteractionEnabled = false
        frozenRowBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            frozenRowBackgroundView.leftAnchor.constraint(equalTo: frozenTopLeftBackgroundView.rightAnchor),
            frozenRowBackgroundView.topAnchor.constraint(equalTo: frozenRowView.topAnchor),
            frozenRowBackgroundView.bottomAnchor.constraint(equalTo: frozenRowView.bottomAnchor),
            frozenRowBackgroundView.rightAnchor.constraint(equalTo: frozenRowView.rightAnchor)
        ])

        eventTitleCollectionView.backgroundColor = .clear
        eventTitleCollectionView.showsVerticalScrollIndicator = false
        eventTitleCollectionView.showsHorizontalScrollIndicator = false
        let layout = eventTitleCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.scrollDirection = .horizontal
        layout.sectionInset = .zero
        layout.minimumInteritemSpacing = 0
        eventTitleCollectionView.translatesAutoresizingMaskIntoConstraints = false
        eventTitleCollectionView.dataSource = self
        eventTitleCollectionView.delegate = self
        frozenRowView.addSubview(eventTitleCollectionView)
        eventTitleCollectionView.activateFitFrameConstarintsToSuperview()

        eventTitleCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "None")
        
        frozenRowView.addSubview(frozenColumnTitleViewContainer)
        frozenColumnTitleViewContainer.translatesAutoresizingMaskIntoConstraints = false
        frozenColumnTitleViewContainerWidthConstraint = frozenColumnTitleViewContainer.widthAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([
            frozenColumnTitleViewContainer.leftAnchor.constraint(equalTo: frozenRowView.leftAnchor),
            frozenColumnTitleViewContainer.topAnchor.constraint(equalTo: frozenRowView.topAnchor),
            frozenColumnTitleViewContainer.bottomAnchor.constraint(equalTo: frozenRowView.bottomAnchor),
            frozenTopLeftBackgroundViewWidthConstraint
        ])
        
        // Sort frozenRowView subviews
        frozenRowView.insertSubview(frozenRowBackgroundView, at: 0)
        frozenRowView.insertSubview(eventTitleCollectionView, at: 1)
        frozenRowView.insertSubview(frozenTopLeftBackgroundView, at: 2)
        frozenRowView.insertSubview(frozenColumnTitleViewContainer, at: 3)
    }

    public func reloadData() {
        layoutDataStore.clear()
        eventScrollView.removeAllAddedCells()
        frozenEventScrollView.removeAllAddedCells()
        survivorManager.resetSurvivorIndexPaths([])
        timeScrollView.removeAllAddedCells()
        guard let dataSource = dataSource else { return }
        layoutDataStore.store(dataSource: dataSource, for: self)
        let eventLayoutData = layoutDataStore.cachedEventScrollViewLayoutData!
        let timeLayoutData = layoutDataStore.cachedTimeScrollViewLayoutData!
        let frozenLayoutData = layoutDataStore.cachedFrozenEventScrollViewLayoutData!
        let existsFrozenEventScrollView: Bool = frozenLayoutData.totalWidthOfColumns > 0
        let frozenEventScrollViewWidth: CGFloat = frozenLayoutData.totalWidthOfColumns > 0
            ? frozenLayoutData.totalWidthOfColumns + frozenLayoutData.totalSpacingOfColumns
            : 0
        let frozenRowHeight: CGFloat = layoutDataStore.cachedHeightOfColumnTitle ?? 0

        frozenRowViewHeightConstraint.constant = frozenRowHeight
        frozenColumnBackgroundViewTopConstraint.constant = frozenRowHeight
        frozenColumnBackgroundViewWidthConstraint.constant = timeLayoutData.widthOfColumn
        if existsFrozenEventScrollView {
            frozenColumnBackgroundViewWidthConstraint.constant += frozenLayoutData.columnSpacing + frozenEventScrollViewWidth
        }
        frozenTopLeftBackgroundViewWidthConstraint.constant = frozenColumnBackgroundViewWidthConstraint.constant
        reInsertTitleViewsIfNeeded()

        //
        // First, set contentInset before set contentSize(set it in setup()), otherwise contentOffset is not correct.
        //
        let halfFontLineHeight: CGFloat = round(TimeCell.preferredFont.lineHeight / 2)
        let scrollViewContentInsetTop: CGFloat = frozenRowHeight + halfFontLineHeight
        let scrollViewContentInsetBottom: CGFloat = halfFontLineHeight

        eventScrollView.contentInset.left = timeLayoutData.widthOfColumn + eventLayoutData.columnSpacing
        if existsFrozenEventScrollView {
            eventScrollView.contentInset.left += frozenLayoutData.columnSpacing + frozenEventScrollViewWidth
        }
        eventScrollView.contentInset.top = scrollViewContentInsetTop
        eventScrollView.contentInset.bottom = scrollViewContentInsetBottom
        eventScrollView.scrollIndicatorInsets = eventScrollView.contentInset
        if let additionalContentInset = additionalContentInset {
            eventScrollView.contentInset.top += additionalContentInset.top
            eventScrollView.contentInset.left += additionalContentInset.left
            eventScrollView.contentInset.right += additionalContentInset.right
            eventScrollView.contentInset.bottom += additionalContentInset.bottom
        }
        eventTitleCollectionView.contentInset.left = eventScrollView.contentInset.left
        let layout = eventTitleCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.minimumLineSpacing = eventLayoutData.columnSpacing
        eventTitleCollectionView.reloadData()
 
        frozenEventScrollView.contentInset.top = scrollViewContentInsetTop
        frozenEventScrollView.contentInset.bottom = scrollViewContentInsetBottom
        frozenEventScrollViewLeftConstraint.constant = existsFrozenEventScrollView
            ? timeLayoutData.widthOfColumn + frozenLayoutData.columnSpacing
            : 0
        frozenEventScrollViewWidthConstraint.constant = frozenEventScrollViewWidth
        eventScrollView.setup(layoutData: eventLayoutData)
        survivorManager.setup(layoutData: eventLayoutData)
        frozenEventScrollView.setup(layoutData: frozenLayoutData)
        insertCellsIntoFrozenScrollView()
        
        timeScrollView.contentInset.top = scrollViewContentInsetTop
        timeScrollView.contentInset.bottom = scrollViewContentInsetBottom
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
        eventTitleCollectionView.contentOffset.x = eventScrollView.contentOffset.x
    }
    
    private func reInsertTitleViewsIfNeeded() {
        frozenColumnTitleViewContainer.subviews.forEach { $0.removeFromSuperview() }
        guard let dataSource = dataSource,
            let timeLayoutData = layoutDataStore.cachedTimeScrollViewLayoutData,
            let frozenLayoutData = layoutDataStore.cachedFrozenEventScrollViewLayoutData
            else { return }
        
        guard frozenRowViewHeightConstraint.constant > 0 else { return }

        var constraints: [NSLayoutConstraint] = []
        
        let superview = frozenColumnTitleViewContainer
        
        if let titleView = dataSource.titleViewOfTimeColumn(in: self) {
            superview.addSubview(titleView)
            titleView.translatesAutoresizingMaskIntoConstraints = false
            constraints.append(contentsOf: [
                titleView.leftAnchor.constraint(equalTo: superview.leftAnchor),
                titleView.topAnchor.constraint(equalTo: superview.topAnchor),
                titleView.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
                titleView.widthAnchor.constraint(equalToConstant: timeLayoutData.widthOfColumn)
            ])
        }
        
        for indexPath in frozenLayoutData.indexPaths {
            let x = timeLayoutData.widthOfColumn + frozenLayoutData.columnSpacing
                + frozenLayoutData.xPositionOfColumn[indexPath]!
            let width = frozenLayoutData.widthOfColumn[indexPath]!
            if let titleView = dataSource.titleViewOfFrozenColumn(at: indexPath, in: self) {
                superview.addSubview(titleView)
                
                titleView.translatesAutoresizingMaskIntoConstraints = false
                constraints.append(contentsOf: [
                    titleView.leftAnchor.constraint(equalTo: superview.leftAnchor, constant: x),
                    titleView.topAnchor.constraint(equalTo: superview.topAnchor),
                    titleView.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
                    titleView.widthAnchor.constraint(equalToConstant: width)
                ])
            }
        }
        
        if constraints.isEmpty == false {
            NSLayoutConstraint.activate(constraints)
        }
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
    
    public func scrollToColumn(at indexPath: IndexPath, animated: Bool, space: CGFloat = 0) {
        guard let dataSource = dataSource,
            let layoutData = layoutDataStore.cachedEventScrollViewLayoutData,
            let xPositionOfColumn = layoutData.xPositionOfColumn[indexPath],
            let cell = dataSource.cells(at: indexPath, in: self).first else { return }
        
        // control contentOffset so that contentOffset exceed contentSize
        let inset: UIEdgeInsets = eventScrollView.contentInset
        var y: CGFloat
        let isScrollableY: Bool
            = eventScrollView.contentSize.height + inset.bottom > eventScrollView.frame.height
        if isScrollableY {
            let maxContentOffsetY: CGFloat = eventScrollView.contentSize.height - eventScrollView.frame.height + inset.bottom
            y = layoutData.roundedDistanceOfTimeRangeStart(to: cell.event.start) - inset.top - space
            y = min(y, maxContentOffsetY)
        } else {
            y = -inset.top
        }

        var x: CGFloat
        let isScrollableX: Bool
            = eventScrollView.contentSize.width + inset.right > eventScrollView.frame.width
        if isScrollableX {
            let maxContentOffsetX: CGFloat = eventScrollView.contentSize.width - eventScrollView.frame.width + inset.right
            x = xPositionOfColumn - inset.left - space
            x = min(x, maxContentOffsetX)
        } else {
            x = -inset.left
        }
        eventScrollView.setContentOffset(CGPoint(x: x, y: y), animated: animated)
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

// MARK: - Interface eventTitleCollectionView methods
extension SamidareView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    public func registerEventTitleCell(_ cellClass: AnyClass?, forCellWithReuseIdentifier: String) {
        eventTitleCollectionView.register(cellClass, forCellWithReuseIdentifier: forCellWithReuseIdentifier)
    }
    
    public func registerEventTitleCell(_ nib: UINib?, forCellWithReuseIdentifier: String) {
        eventTitleCollectionView.register(nib, forCellWithReuseIdentifier: forCellWithReuseIdentifier)
    }
    
    public func dequeueReusableEventTitleCell(withReuseIdentifier identifier: String, for indexPath: IndexPath) -> UICollectionViewCell {
        return eventTitleCollectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
    }

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let layoutData = layoutDataStore.cachedEventScrollViewLayoutData else { return 0 }
        return Set(layoutData.indexPaths.map({ $0.section })).count
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let layoutData = layoutDataStore.cachedEventScrollViewLayoutData else { return 0 }
        return layoutData.indexPaths.filter({ $0.section == section }).count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return dataSource?.titleCellOfEventColumn(at: indexPath, in: self)
                ?? eventTitleCollectionView.dequeueReusableCell(withReuseIdentifier: "None", for: indexPath)
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let layoutData = layoutDataStore.cachedEventScrollViewLayoutData else { return .zero }
        let convertedIndexPath = layoutData.indexPaths[indexPath.item]
        return CGSize(width: layoutData.widthOfColumn[convertedIndexPath]!, height: collectionView.bounds.height)
    }
}
