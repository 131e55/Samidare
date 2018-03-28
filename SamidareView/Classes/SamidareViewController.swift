//
//  SamidareViewController.swift
//  SamidareView
//
//  Created by Keisuke Kawamura on 2018/03/22.
//

import UIKit


public protocol SamidareViewDataSource: class {

    func timeRange(in samidareView: SamidareView) -> TimeRange
    func numberOfColumns(in samidareView: SamidareView) -> Int
    func events(in samidareView: SamidareView, inColumn column: Int) -> [Event]
}


public protocol SamidareViewDelegate: class {

    func widthForTimeColumn(in samidareView: SamidareView) -> CGFloat
    func widthForEventColumn(in samidareView: SamidareView) -> CGFloat
    func heightPerMinInterval(in samidareView: SamidareView) -> CGFloat
    func eventView(in samidareView: SamidareView, inColumn column: Int, for event: Event) -> EventView
}


open class SamidareViewController: UIViewController {

    public weak var dataSource: SamidareViewDataSource? {
        didSet { samidareView.dataSource = dataSource }
    }
    public weak var delegate: SamidareViewDelegate? {
        didSet { samidareView.delegate = delegate }
    }

    private weak var samidareView: SamidareView!
    private weak var timeTableView: UITableView!

    open override func viewDidLoad() {

        super.viewDidLoad()

        let samidareView = SamidareView()
        samidareView.backgroundColor = .clear
        samidareView.scrollView.delegate = self
        view.addSubview(samidareView)
        samidareView.translatesAutoresizingMaskIntoConstraints = false
        samidareView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        samidareView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        samidareView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        samidareView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        self.samidareView = samidareView

        let tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.isUserInteractionEnabled = false
        tableView.register(SamidareTimeCell.self, forCellReuseIdentifier: "SamidareTimeCell")
        tableView.dataSource = self
        tableView.delegate = self
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.contentInset.top = SamidareTimeCell.font.lineHeight / 2
        tableView.contentInset.bottom = SamidareTimeCell.font.lineHeight / 2
        timeTableView = tableView
    }

    public func reload() {

        timeTableView.reloadData()
        samidareView.reload()

        // Fit samidareView contentInset to timeLabel
        let timeColumnWidth = delegate?.widthForTimeColumn(in: samidareView) ?? 50
        let additionalInsetLeft: CGFloat = 8
        let timeLabelCenterY = SamidareTimeCell.preferredTimeLabelCenterY
        let inset = UIEdgeInsets(top: timeTableView.contentInset.top + timeLabelCenterY,
                                 left: timeColumnWidth + additionalInsetLeft,
                                 bottom: timeTableView.contentInset.bottom + timeLabelCenterY,
                                 right: samidareView.scrollView.contentInset.right)
        samidareView.scrollView.contentInset = inset
        samidareView.scrollView.scrollIndicatorInsets.left = timeColumnWidth + additionalInsetLeft
    }
}

extension SamidareViewController: UITableViewDataSource {

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        guard let dataSource = dataSource else { fatalError("😿SamidareViewDataSource has not been implemented😿") }

        let timeRange = dataSource.timeRange(in: samidareView)
        let floorStartTime = Time(hours: timeRange.start.hours, minutes: 0)
        let ceilEndTime = Time(hours: timeRange.end.hours + 1, minutes: 0)
        let number = ceilEndTime.hours - floorStartTime.hours + 1

        return number
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let dataSource = dataSource else { fatalError("😿SamidareViewDataSource has not been implemented😿") }

        let timeRange = dataSource.timeRange(in: samidareView)
        let numberOfRows = self.tableView(tableView, numberOfRowsInSection: indexPath.section)
        let cell = tableView.dequeueReusableCell(withIdentifier: "SamidareTimeCell", for: indexPath) as! SamidareTimeCell
        let width = delegate?.widthForTimeColumn(in: samidareView) ?? 50

        switch indexPath.row {
        case 0:
            cell.configure(timeText: timeRange.start.formattedString, timeViewWidth: width)

        case numberOfRows - 1:
            cell.configure(timeText: timeRange.end.formattedString, timeViewWidth: width)

        default:
            let time = Time(hours: timeRange.start.hours + indexPath.row, minutes: 0)
            cell.configure(timeText: time.formattedString, timeViewWidth: width)
        }

        return cell
    }
}

extension SamidareViewController: UITableViewDelegate {

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        guard let dataSource = dataSource else { fatalError("😿SamidareViewDataSource has not been implemented😿") }

        let timeRange = dataSource.timeRange(in: samidareView)
        let numberOfRows = self.tableView(tableView, numberOfRowsInSection: indexPath.section)
        let minInterval = dataSource.timeRange(in: samidareView).minInterval
        let heightPerIntervals = delegate?.heightPerMinInterval(in: samidareView) ?? samidareView.defaultHeightPerInterval

        switch indexPath.row {
        case 0:
            // ex.1) start 4:30 -> 5:00 - 4:30 = 0:30, ex.2) start 4:15 -> 5:00 - 4:15 = 0:45
            let nextTime = Time(hours: timeRange.start.hours + 1, minutes: 0)
            let interval = nextTime.totalMinutes - timeRange.start.totalMinutes
            let numberOfIntervals = interval / minInterval
            return CGFloat(numberOfIntervals) * heightPerIntervals

        case numberOfRows - 2:
            let time = Time(hours: timeRange.start.hours + indexPath.row, minutes: 0)
            let interval = timeRange.end.totalMinutes - time.totalMinutes
            let numberOfIntervals = interval / minInterval
            return CGFloat(numberOfIntervals) * heightPerIntervals

        case numberOfRows - 1:
            return SamidareTimeCell.font.lineHeight

        default:
            let numberOfIntervals = 60 / minInterval
            return CGFloat(numberOfIntervals) * heightPerIntervals
        }
    }
}

extension SamidareViewController: UIScrollViewDelegate {

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {

        // Sync timeTableView scroll position to samidareView
        guard scrollView == samidareView.scrollView && scrollView.contentSize.height > 0 else { return }
        timeTableView.contentOffset.y = scrollView.contentOffset.y + scrollView.contentInset.top - timeTableView.contentInset.top
    }
}
