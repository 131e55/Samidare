//
//  SamidareView.swift
//  SamidareView
//
//  Created by Keisuke Kawamura on 2018/03/26.
//

import UIKit

open class SamidareView: UIView {

    public weak var dataSource: SamidareViewDataSource?
    public weak var delegate: SamidareViewDelegate?

    private(set) weak var scrollView: UIScrollView!
    private weak var contentView: UIView!
    private weak var stackView: UIStackView!

    private var contentViewWidthConstraint: NSLayoutConstraint!
    private var contentViewHeightConstraint: NSLayoutConstraint!

    internal let defaultWidthForColumn: CGFloat = 44
    internal let defaultHeightPerInterval: CGFloat = 10

    internal var numberOfSeparators: Int {

        guard let dataSource = dataSource else { return 0 }

        let timeRange = dataSource.timeRange(in: self)
        let floorStartTime = Time(hours: timeRange.start.hours, minutes: 0)
        let ceilEndTime = Time(hours: timeRange.end.hours + 1, minutes: 0)
        let number = ceilEndTime.hours - floorStartTime.hours + 1
        return number
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {

        let scrollView = UIScrollView()
        scrollView.bounces = true
        scrollView.alwaysBounceHorizontal = false
        scrollView.alwaysBounceVertical = false
        scrollView.isDirectionalLockEnabled = true
        addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        self.scrollView = scrollView

        let contentView = UIView()
        contentView.backgroundColor = .clear
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        contentViewWidthConstraint = contentView.widthAnchor.constraint(equalToConstant: 0)
        contentViewWidthConstraint.isActive = true
        contentViewHeightConstraint = contentView.heightAnchor.constraint(equalToConstant: 0)
        contentViewHeightConstraint.isActive = true
        self.contentView = contentView

        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        self.stackView = stackView
    }

    public func reload() {

        layoutContentView()
        reloadStackView()
    }

    private func layoutContentView() {

        guard let dataSource = dataSource else { return }

        let timeRange = dataSource.timeRange(in: self)
        let numberOfColumns = dataSource.numberOfColumns(in: self)
        let numberOfIntervals = timeRange.numberOfIntervals
        let widthForColumn = delegate?.widthForEventColumn(in: self) ?? defaultWidthForColumn
        let heightPerInterval = delegate?.heightPerMinInterval(in: self) ?? defaultHeightPerInterval

        contentViewWidthConstraint.constant = CGFloat(numberOfColumns) * widthForColumn
        contentViewHeightConstraint.constant = heightPerInterval * CGFloat(numberOfIntervals)
    }

    private func reloadStackView() {

        guard let dataSource = dataSource else { return }

        let timeRange = dataSource.timeRange(in: self)
        let numberOfColumns = dataSource.numberOfColumns(in: self)
        let heightPerInterval = delegate?.heightPerMinInterval(in: self) ?? defaultHeightPerInterval

        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for column in 0 ..< numberOfColumns {

            let columnView = UIView()
//            columnView.backgroundColor = [.lightGray, .gray, .darkGray][column % 3]
            stackView.addArrangedSubview(columnView)

            let events = dataSource.events(in: self, inColumn: column)

            for event in events {

                let eventView = EventView(event: event)
                eventView.backgroundColor = [.red, .green, .blue][column % 3]
                columnView.addSubview(eventView)
                eventView.translatesAutoresizingMaskIntoConstraints = false
                eventView.leadingAnchor.constraint(equalTo: columnView.leadingAnchor).isActive = true
                eventView.trailingAnchor.constraint(equalTo: columnView.trailingAnchor).isActive = true

                let topInterval = (event.start.totalMinutes - timeRange.start.totalMinutes) / timeRange.minInterval
                let topConstraint = eventView.topAnchor.constraint(equalTo: columnView.topAnchor)
                topConstraint.constant = CGFloat(topInterval) * heightPerInterval
                topConstraint.isActive = true

                let duration = (event.end.totalMinutes - event.start.totalMinutes) / timeRange.minInterval
                let heightConstraint = eventView.heightAnchor.constraint(equalToConstant: 0)
                heightConstraint.constant = CGFloat(duration) * heightPerInterval
                heightConstraint.isActive = true
            }
        }
    }
}
