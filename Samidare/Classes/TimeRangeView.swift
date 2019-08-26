//
//  TimeRangeView.swift
//  Samidare
//
//  Created by Keisuke Kawamura on 2019/07/17.
//

import UIKit

internal final class TimeRangeView: UIView {
    private static let nib: UINib = UINib(nibName: "TimeRangeView", bundle: Bundle(for: TimeRangeView.self))

    @IBOutlet private weak var startTimeView: UIView!
    @IBOutlet private weak var startTimeLabel: UILabel!
    @IBOutlet private weak var endTimeView: UIView!
    @IBOutlet private weak var endTimeLabel: UILabel!
    
    var color: UIColor = .white {
        didSet {
            startTimeView.backgroundColor = color
            endTimeView.backgroundColor = color
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 44, height: UIView.noIntrinsicMetric)
    }
    
    init() {
        super.init(frame: .zero)
        didInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        didInit()
    }
    
    private func didInit() {
        let view = type(of: self).nib.instantiate(withOwner: self, options: nil).first as! UIView
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        NSLayoutConstraint.activate([view.leftAnchor.constraint(equalTo: leftAnchor),
                                     view.topAnchor.constraint(equalTo: topAnchor),
                                     view.rightAnchor.constraint(equalTo: rightAnchor),
                                     view.bottomAnchor.constraint(equalTo: bottomAnchor)])
    }
    
    internal func update(timeRange: ClosedRange<Date>) {
        startTimeLabel.text = String.timeText(date: timeRange.lowerBound)
        endTimeLabel.text = String.timeText(date: timeRange.upperBound)
    }
    
    internal func bringStartViewToFront() {
        startTimeView.superview!.bringSubviewToFront(startTimeView)
    }

    internal func bringEndViewToFront() {
        endTimeView.superview!.bringSubviewToFront(endTimeView)
    }
}
