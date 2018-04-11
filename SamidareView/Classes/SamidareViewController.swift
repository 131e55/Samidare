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

    func eventViewDidTap(in samidareView: SamidareView, eventView: EventView)
    func eventDidEdit(in samidareView: SamidareView, newEvent: Event, oldEvent: Event)
}


open class SamidareViewController: UIViewController {

    public weak var dataSource: SamidareViewDataSource? {
        didSet { samidareView?.dataSource = dataSource }
    }
    public weak var delegate: SamidareViewDelegate? {
        didSet { samidareView?.delegate = delegate }
    }

    private weak var samidareView: SamidareView!
    private weak var timeInformationView: TimeInformationView!

    open override func viewDidLoad() {

        super.viewDidLoad()

        let samidareView = SamidareView()
        samidareView.backgroundColor = .clear
        samidareView.dataSource = dataSource
        samidareView.delegate = delegate
        samidareView.scrollView.delegate = self
        view.addSubview(samidareView)
        samidareView.translatesAutoresizingMaskIntoConstraints = false
        samidareView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        samidareView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        samidareView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        samidareView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        self.samidareView = samidareView

        let timeView = TimeInformationView()
        timeView.layoutDelegate = self
        timeView.backgroundColor = .clear
        timeView.isUserInteractionEnabled = false
        view.addSubview(timeView)
        timeView.translatesAutoresizingMaskIntoConstraints = false
        timeView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        timeView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        timeView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        timeView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        timeView.scrollView.contentInset.top = TimeInformationCell.preferredFont.lineHeight / 2
        timeView.scrollView.contentInset.bottom = TimeInformationCell.preferredFont.lineHeight / 2
        self.timeInformationView = timeView
    }

    public func reload() {

        samidareView.reload()
        timeInformationView.reload()

        // Fit samidareView contentInset to timeLabel
        let timeColumnWidth = delegate?.widthForTimeColumn(in: samidareView) ?? 50
        let additionalInsetLeft: CGFloat = 8
        let timeFontHeight = TimeInformationCell.preferredFont.lineHeight
        let timeViewContentInset = timeInformationView.scrollView.contentInset
        let inset = UIEdgeInsets(top: timeViewContentInset.top + timeFontHeight / 2,
                                 left: timeColumnWidth + additionalInsetLeft,
                                 bottom: timeViewContentInset.bottom + timeFontHeight / 2,
                                 right: samidareView.scrollView.contentInset.right)
        samidareView.scrollView.contentInset = inset
        samidareView.scrollView.scrollIndicatorInsets.left = timeColumnWidth + additionalInsetLeft
    }
}

extension SamidareViewController: TimeInformationViewLayoutDelegate {

    func numberOfRows(in timeInformationView: TimeInformationView) -> Int {

        guard let dataSource = dataSource else { print("😿SamidareViewDataSource has not been implemented😿"); return 0 }

        let timeRange = dataSource.timeRange(in: samidareView)
        let floorStartTime = Time(hours: timeRange.start.hours, minutes: 0)
        let ceilEndTime = Time(hours: timeRange.end.hours + 1, minutes: 0)
        let number = ceilEndTime.hours - floorStartTime.hours + 1

        return number
    }

    func height(forRowAt row: Int, in timeInformationView: TimeInformationView) -> CGFloat {

        guard let dataSource = dataSource else { print("😿SamidareViewDataSource has not been implemented😿"); return 0 }

        let timeRange = dataSource.timeRange(in: samidareView)
        let numberOfRows = timeInformationView.numberOfRows
        let minInterval = dataSource.timeRange(in: samidareView).minInterval
        let heightPerIntervals = delegate?.heightPerMinInterval(in: samidareView) ?? samidareView.defaultHeightPerInterval

        switch row {
        case 0:
            // ex.1) start 4:30 -> 5:00 - 4:30 = 0:30, ex.2) start 4:15 -> 5:00 - 4:15 = 0:45
            let nextTime = Time(hours: timeRange.start.hours + 1, minutes: 0)
            let interval = nextTime.totalMinutes - timeRange.start.totalMinutes
            let numberOfIntervals = interval / minInterval
            return CGFloat(numberOfIntervals) * heightPerIntervals

        case numberOfRows - 2:
            let time = Time(hours: timeRange.start.hours + row, minutes: 0)
            let interval = timeRange.end.totalMinutes - time.totalMinutes
            let numberOfIntervals = interval / minInterval
            return CGFloat(numberOfIntervals) * heightPerIntervals

        case numberOfRows - 1:
            return TimeInformationCell.preferredFont.lineHeight

        default:
            let numberOfIntervals = 60 / minInterval
            return CGFloat(numberOfIntervals) * heightPerIntervals
        }
    }

    func cell(forRowAt row: Int, in timeInformationView: TimeInformationView) -> TimeInformationCell {

        guard let dataSource = dataSource else {
            print("😿SamidareViewDataSource has not been implemented😿")
            return TimeInformationCell(timeText: "")
        }

        let timeRange = dataSource.timeRange(in: samidareView)
        let numberOfRows = timeInformationView.numberOfRows
        let width = delegate?.widthForTimeColumn(in: samidareView) ?? 50

        let timeText: String

        switch row {
        case 0:
            timeText = timeRange.start.formattedString

        case numberOfRows - 1:
            timeText = timeRange.end.formattedString

        default:
            timeText = Time(hours: timeRange.start.hours + row, minutes: 0).formattedString
        }

        let cell = TimeInformationCell(timeText: timeText, timeViewWidth: width)
        cell.timeView.backgroundColor = view.backgroundColor

        return cell
    }
}

extension SamidareViewController: UIScrollViewDelegate {

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {

        // Sync timeTableView scroll position to samidareView
        guard scrollView == samidareView.scrollView && scrollView.contentSize.height > 0 else { return }
        timeInformationView.scrollView.contentOffset.y = scrollView.contentOffset.y + scrollView.contentInset.top
                                                         - timeInformationView.scrollView.contentInset.top
    }
}
