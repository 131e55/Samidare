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

    // Cache of Delegate
    private var widthForTimeColumn: CGFloat = 50


    open override func viewDidLoad() {

        super.viewDidLoad()

        let samidareView = SamidareView()
        samidareView.backgroundColor = .clear
        samidareView.dataSource = dataSource
        samidareView.delegate = delegate
        samidareView.scrollView.delegate = self
        view.addSubview(samidareView)
        samidareView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            samidareView.topAnchor.constraint(equalTo: view.topAnchor),
            samidareView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            samidareView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            samidareView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        self.samidareView = samidareView

        let timeView = TimeInformationView()
        timeView.layoutDelegate = self
        timeView.backgroundColor = .clear
        timeView.isUserInteractionEnabled = false
        view.addSubview(timeView)
        timeView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            timeView.topAnchor.constraint(equalTo: view.topAnchor),
            timeView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            timeView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            timeView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        timeView.scrollView.contentInset.top = TimeInformationCell.preferredFont.lineHeight / 2
        timeView.scrollView.contentInset.bottom = TimeInformationCell.preferredFont.lineHeight / 2
        self.timeInformationView = timeView
    }

    public func reload() {

        samidareView.reload()
        timeInformationView.reload()

        // Fit samidareView contentInset to timeLabel
        widthForTimeColumn = delegate?.widthForTimeColumn(in: samidareView) ?? 50
        let additionalInsetLeft: CGFloat = 8
        let timeFontHeight = TimeInformationCell.preferredFont.lineHeight
        let timeViewContentInset = timeInformationView.scrollView.contentInset
        let inset = UIEdgeInsets(top: timeViewContentInset.top + timeFontHeight / 2,
                                 left: widthForTimeColumn + additionalInsetLeft,
                                 bottom: timeViewContentInset.bottom + timeFontHeight / 2,
                                 right: samidareView.scrollView.contentInset.right)
        samidareView.scrollView.contentInset = inset
        samidareView.scrollView.scrollIndicatorInsets.left = widthForTimeColumn + additionalInsetLeft
    }

    /// Wrapper samidareView.scrollView.setContentOffset
    public func setContentOffset(_ contentOffset: CGPoint, animated: Bool) {
        samidareView.scrollView.setContentOffset(contentOffset, animated: animated)
    }
}

extension SamidareViewController: TimeInformationViewLayoutDelegate {

    func numberOfRows(in timeInformationView: TimeInformationView) -> Int {

        let timeRange = samidareView.timeRange
        let floorStartTime = Time(hours: timeRange.start.hours, minutes: 0)
        let ceilEndTime = Time(hours: timeRange.end.hours + 1, minutes: 0)
        let number = ceilEndTime.hours - floorStartTime.hours + 1

        return number
    }

    func height(forRowAt row: Int, in timeInformationView: TimeInformationView) -> CGFloat {

        let timeRange = samidareView.timeRange
        let numberOfRows = timeInformationView.numberOfRows
        let heightPerIntervals = samidareView.heightPerMinInterval

        switch row {
        case 0:
            // ex.1) start 4:30 -> 5:00 - 4:30 = 0:30, ex.2) start 4:15 -> 5:00 - 4:15 = 0:45
            let nextTime = Time(hours: timeRange.start.hours + 1, minutes: 0)
            let interval = nextTime.totalMinutes - timeRange.start.totalMinutes
            let numberOfIntervals = interval / timeRange.minInterval
            return CGFloat(numberOfIntervals) * heightPerIntervals

        case numberOfRows - 2:
            let time = Time(hours: timeRange.start.hours + row, minutes: 0)
            let interval = timeRange.end.totalMinutes - time.totalMinutes
            let numberOfIntervals = interval / timeRange.minInterval
            return CGFloat(numberOfIntervals) * heightPerIntervals

        case numberOfRows - 1:
            return TimeInformationCell.preferredFont.lineHeight

        default:
            let numberOfIntervals = 60 / timeRange.minInterval
            return CGFloat(numberOfIntervals) * heightPerIntervals
        }
    }

    func cell(forRowAt row: Int, in timeInformationView: TimeInformationView) -> TimeInformationCell {

        let timeRange = samidareView.timeRange
        let numberOfRows = timeInformationView.numberOfRows
        let width = widthForTimeColumn
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
