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

    private let frozenBackgroundView: UIVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
    private let frozenBackgroundView2: UIVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))

    private let titleViewContainer: UIView = UIView()
    private var titleViewContainerHeightConstraint: NSLayoutConstraint!
    
    private let eventScrollView: EventScrollView = EventScrollView()
    private let timeScrollView: TimeScrollView = TimeScrollView()
    private let frozenEventScrollView: EventScrollView = EventScrollView()
    private var frozenEventScrollViewWidthConstraint: NSLayoutConstraint!
    private var frozenEventScrollViewLeftConstraint: NSLayoutConstraint!

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

        frozenBackgroundView.isUserInteractionEnabled = false
        frozenBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(frozenBackgroundView)
        NSLayoutConstraint.activate([
            frozenBackgroundView.leftAnchor.constraint(equalTo: leftAnchor),
            frozenBackgroundView.topAnchor.constraint(equalTo: topAnchor, constant: 44),
            frozenBackgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),
            frozenBackgroundView.widthAnchor.constraint(equalToConstant: 108)
        ])
//        frozenBackgroundView.activateFitFrameConstarintsToSuperview()
        
        titleViewContainer.translatesAutoresizingMaskIntoConstraints = false
        titleViewContainerHeightConstraint = titleViewContainer.heightAnchor.constraint(equalToConstant: 0)
        addSubview(titleViewContainer)
        NSLayoutConstraint.activate([
            titleViewContainer.leftAnchor.constraint(equalTo: leftAnchor),
            titleViewContainer.topAnchor.constraint(equalTo: topAnchor),
            titleViewContainer.rightAnchor.constraint(equalTo: rightAnchor),
            titleViewContainerHeightConstraint
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
        
        frozenBackgroundView2.isUserInteractionEnabled = false
        frozenBackgroundView2.translatesAutoresizingMaskIntoConstraints = false
        addSubview(frozenBackgroundView2)
        NSLayoutConstraint.activate([
            frozenBackgroundView2.leftAnchor.constraint(equalTo: leftAnchor),
            frozenBackgroundView2.topAnchor.constraint(equalTo: topAnchor),
            frozenBackgroundView2.rightAnchor.constraint(equalTo: rightAnchor),
            frozenBackgroundView2.heightAnchor.constraint(equalToConstant: 44)
        ])
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
        
        // Reset FrozenBackgroundView mask rule
        let frozenBackgroundWidth: CGFloat = timeLayoutData.widthOfColumn
                                             + frozenLayoutData.columnSpacing
                                             + frozenLayoutData.totalWidthOfColumns
                                             + frozenLayoutData.totalSpacingOfColumns
        let frozenBackgroundHeight: CGFloat = layoutDataStore.cachedHeightOfColumnTitle ?? 0
        let maskLayer = CAShapeLayer()
        let maskPath = CGMutablePath()
        maskPath.addPath(CGPath(rect: bounds, transform: nil))
        maskPath.addPath(CGPath(rect: CGRect(x: frozenBackgroundWidth,
                                             y: frozenBackgroundHeight,
                                             width: bounds.width - frozenBackgroundWidth,
                                             height: bounds.height - frozenBackgroundHeight),
                                transform: nil))
        maskLayer.path = maskPath
        maskLayer.fillRule = .evenOdd
//        frozenBackgroundView.layer.mask = maskLayer
        
        reInsertTitleViewsIfNeeded()

        //
        // First, set contentInset before set contentSize(set it in setup()), otherwise contentOffset is not correct.
        //
        let halfFontLineHeight: CGFloat = round(TimeCell.preferredFont.lineHeight / 2)
        let scrollViewContentInsetTop: CGFloat = frozenBackgroundHeight + halfFontLineHeight
        let scrollViewContentInsetBottom: CGFloat = halfFontLineHeight

        eventScrollView.contentInset.left = timeLayoutData.widthOfColumn
                                            + frozenLayoutData.columnSpacing
                                            + frozenLayoutData.totalWidthOfColumns
                                            + frozenLayoutData.totalSpacingOfColumns
                                            + eventLayoutData.columnSpacing
        eventScrollView.contentInset.right = eventLayoutData.columnSpacing
        eventScrollView.contentInset.top = scrollViewContentInsetTop
        eventScrollView.contentInset.bottom = scrollViewContentInsetBottom
        eventScrollView.scrollIndicatorInsets = eventScrollView.contentInset
 
        frozenEventScrollView.contentInset.top = scrollViewContentInsetTop
        frozenEventScrollView.contentInset.bottom = scrollViewContentInsetBottom
        frozenEventScrollViewLeftConstraint.constant = timeLayoutData.widthOfColumn
                                                       + frozenLayoutData.columnSpacing
        frozenEventScrollViewWidthConstraint.constant = frozenLayoutData.totalWidthOfColumns
                                                        + frozenLayoutData.totalSpacingOfColumns
        
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
    }
    
    private func reInsertTitleViewsIfNeeded() {
        guard let dataSource = dataSource,
            let timeLayoutData = layoutDataStore.cachedTimeScrollViewLayoutData else { return }

        titleViewContainer.subviews.forEach { $0.removeFromSuperview() }
        titleViewContainerHeightConstraint.constant = layoutDataStore.cachedHeightOfColumnTitle ?? 0
        guard titleViewContainerHeightConstraint.constant > 0 else { return }

        var constraints: [NSLayoutConstraint] = []
        
        if let timeTitleView = dataSource.titleViewOfTimeColumn(in: self) {
            dprint(timeTitleView)
            timeTitleView.translatesAutoresizingMaskIntoConstraints = false
            titleViewContainer.addSubview(timeTitleView)
            constraints.append(contentsOf: [
                timeTitleView.leftAnchor.constraint(equalTo: titleViewContainer.leftAnchor),
                timeTitleView.topAnchor.constraint(equalTo: titleViewContainer.topAnchor),
                timeTitleView.bottomAnchor.constraint(equalTo: titleViewContainer.bottomAnchor),
                timeTitleView.widthAnchor.constraint(equalToConstant: timeLayoutData.widthOfColumn)
            ])
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
