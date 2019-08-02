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
    private let timeScrollView = TimeScrollView()
    private let frozenBackgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
    private var frozenBackgroundViewWidthConstraint: NSLayoutConstraint!

    public var expansionRateOfSurvivorArea: CGFloat {
        get { return survivorManager.expansionRateOfSurvivorArea }
        set { survivorManager.expansionRateOfSurvivorArea = newValue }
    }
    /// If you want to use EventCreator, implement it.
    public var willCreateEventHandler: CreatorWillCreateEventHandler? {
        didSet {
            if let handler = willCreateEventHandler {
                dprint("call")
                eventScrollView.setupCreator(willCreateEventHandler: handler)
            }
        }
    }
    // TODO:
    public var didUpdateCreatingEventHandler: (() -> Void)?

    // TODO:
    public var didBeginEditingEventHandler: (() -> Void)?
    // TODO:
    public var didEditEventHandler: (() -> Void)?

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
        eventScrollView.frame = bounds
        eventScrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        eventScrollView.autoresizesSubviews = false
        eventScrollView.contentInset = UIEdgeInsets(top: inset, left: 0, bottom: inset, right: 0)
        addSubview(eventScrollView)
        NotificationCenter.default.addObserver(self, selector: #selector(eventScrollViewDidScroll),
                                               name: EventScrollView.didScrollNotification, object: nil)

        frozenBackgroundView.isUserInteractionEnabled = false
        frozenBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(frozenBackgroundView)
        frozenBackgroundViewWidthConstraint = frozenBackgroundView.widthAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([
            frozenBackgroundView.leftAnchor.constraint(equalTo: leftAnchor),
            frozenBackgroundView.topAnchor.constraint(equalTo: topAnchor),
            frozenBackgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),
            frozenBackgroundViewWidthConstraint
        ])

        timeScrollView.frame = bounds
        timeScrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        timeScrollView.autoresizesSubviews = false
        timeScrollView.isUserInteractionEnabled = false
        timeScrollView.contentInset = UIEdgeInsets(top: inset, left: 0, bottom: inset, right: 0)
        addSubview(timeScrollView)
    }

    public func reloadData() {
        dprint("SamidareView reloadData")
        layoutDataStore.clear()
        guard let dataSource = dataSource else { return }
        layoutDataStore.store(dataSource: dataSource, for: self)
        let layoutData = layoutDataStore.cachedData!

        // First, set contentInset before set contentSize(set it in setup()), otherwise contentOffset is not correct.
        eventScrollView.contentInset.left = layoutData.widthOfTimeColumn + layoutData.columnSpacing
        eventScrollView.contentInset.right = layoutData.columnSpacing
        eventScrollView.scrollIndicatorInsets.left = eventScrollView.contentInset.left
        eventScrollView.scrollIndicatorInsets.right = eventScrollView.contentInset.right
        eventScrollView.setup(layoutData: layoutData)
        survivorManager.setup(layoutData: layoutData)
        timeScrollView.setup(layoutData: layoutData)

        frozenBackgroundViewWidthConstraint.constant = layoutData.widthOfTimeColumn

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
        layoutScrollView()
        timeScrollView.contentOffset.y = eventScrollView.contentOffset.y
    }

    private func layoutScrollView() {
        guard let dataSource = dataSource else { return }

        let insertIndexPaths = Array(survivorManager.judgeResult.difference.birth).sorted()
        for indexPath in insertIndexPaths {
            let cells = dataSource.cells(at: indexPath, in: self)
            if !cells.isEmpty {
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
        setNeedsLayout()
    }
}
