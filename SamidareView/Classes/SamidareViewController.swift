//
//  SamidareViewController.swift
//  SamidareView
//
//  Created by Keisuke Kawamura on 2018/03/22.
//

import UIKit


open class SamidareViewController: UIViewController {

    public var timeUnit = 10 {
        didSet { samidareView.timeUnit = timeUnit }
    }
    public var startTime = Time(hours: 0, minutes: 0) {
        didSet { samidareView.startTime = startTime }
    }
    public var endTime = Time(hours: 24, minutes: 0) {
        didSet { samidareView.endTime = endTime }
    }

    public var heightPerUnit: CGFloat = 10 {
        didSet { samidareView.heightPerUnit = heightPerUnit }
    }

    private weak var timeTableView: UITableView!
    private weak var samidareView: SamidareView!

    public weak var dataSource: SamidareViewDataSource? {
        didSet { samidareView.dataSource = dataSource }
    }

    open override func viewDidLoad() {

        super.viewDidLoad()

        print(startTime)
        print(endTime)

        let tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.register(SamidareTimeCell.self, forCellReuseIdentifier: "SamidareTimeCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.widthAnchor.constraint(equalToConstant: 64).isActive = true
        timeTableView = tableView

        let samidareView = SamidareView()
        view.addSubview(samidareView)
        samidareView.translatesAutoresizingMaskIntoConstraints = false
        samidareView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        samidareView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        samidareView.leadingAnchor.constraint(equalTo: timeTableView.trailingAnchor).isActive = true
        samidareView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        self.samidareView = samidareView
    }

    public func reload() {

        timeTableView.reloadData()
        samidareView.reload()
    }
}

extension SamidareViewController: UITableViewDataSource {

    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        let floorStartTime = Time(hours: startTime.hours, minutes: 0)
        let ceilEndTime = Time(hours: endTime.hours + 1, minutes: 0)
        let numberOfRows = ceilEndTime.hours - floorStartTime.hours + 1
        return numberOfRows
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let numberOfRows = self.tableView(tableView, numberOfRowsInSection: indexPath.section)
        let cell = tableView.dequeueReusableCell(withIdentifier: "SamidareTimeCell", for: indexPath) as! SamidareTimeCell

        if indexPath.row == 0 {
            cell.timeLabel.text = startTime.formattedString
        } else if indexPath.row == numberOfRows - 1 {
            cell.timeLabel.text = endTime.formattedString
        } else {
            let time = Time(hours: startTime.hours + indexPath.row, minutes: 0)
            cell.timeLabel.text = time.formattedString
        }

        return cell
    }
}

extension SamidareViewController: UITableViewDelegate {

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 32
    }
}

public protocol SamidareViewDataSource: class {

    func numberOfColumns(in samidareView: SamidareView) -> Int
    func events(in samidareView: SamidareView, inColumn column: Int) -> [Event]
}

open class SamidareView: UIView {

    private weak var scrollView: UIScrollView!
    private weak var stackView: UIStackView!

    private var contentViewWidthConstraint: NSLayoutConstraint!
    private var contentViewHeightConstraint: NSLayoutConstraint!

    public var contentHeight: CGFloat = 0 {
        didSet { layoutContentView() }
    }

    public var timeUnit = 10 {
        didSet { timeUnit = min(max(timeUnit, 0), 59) }
    }

    public var startTime = Time(hours: 0, minutes: 0)
    public var endTime = Time(hours: 24, minutes: 0)

    public var heightPerUnit: CGFloat = 10
    public var columnWidth: CGFloat = 44

    public weak var dataSource: SamidareViewDataSource?

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
        let numberOfColumns = dataSource.numberOfColumns(in: self)

        let floorStartTime = Time(hours: startTime.hours,
                                  minutes: startTime.minutes / timeUnit * timeUnit)
        var ceilEndTime = Time(hours: endTime.hours, minutes: endTime.minutes)
        let modulo = ceilEndTime.minutes % timeUnit
        if modulo > 0 {
            ceilEndTime.minutes -= modulo
            ceilEndTime.minutes += timeUnit
        }

        let numberOfRows = (ceilEndTime.totalMinutes - floorStartTime.totalMinutes) / timeUnit
        contentViewWidthConstraint.constant = CGFloat(numberOfColumns) * columnWidth
        contentViewHeightConstraint.constant = heightPerUnit * CGFloat(numberOfRows)
    }

    private func reloadStackView() {

        guard let dataSource = dataSource else { return }
        let numberOfColumns = dataSource.numberOfColumns(in: self)

        for view in stackView.arrangedSubviews {
            view.removeFromSuperview()
        }

        for column in 0 ..< numberOfColumns {
            let columnView = UIView()
            columnView.backgroundColor = [.lightGray, .gray, .darkGray][column % 3]
            stackView.addArrangedSubview(columnView)

            let events = dataSource.events(in: self, inColumn: column)
            for event in events {
                let eventView = UIView()
                eventView.backgroundColor = [.red, .green, .blue][column % 3]
                columnView.addSubview(eventView)
                eventView.translatesAutoresizingMaskIntoConstraints = false
                eventView.topAnchor.constraint(equalTo: columnView.topAnchor, constant: 10).isActive = true
                eventView.leadingAnchor.constraint(equalTo: columnView.leadingAnchor).isActive = true
                eventView.trailingAnchor.constraint(equalTo: columnView.trailingAnchor).isActive = true
                eventView.heightAnchor.constraint(equalToConstant: 100).isActive = true
            }
        }
    }
}



