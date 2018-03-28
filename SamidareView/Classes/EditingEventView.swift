//
//  EditingEventView.swift
//  SamidareView
//
//  Created by Keisuke Kawamura on 2018/03/27.
//

import UIKit


class EditingEventView: UIView {

    /// Only reference. Not subview.
    private(set) weak var targetEventView: EventView!

    private(set) var event: Event!
    private(set) var estimatedStartTime: Time!
    private(set) var estimatedEndTime: Time!

    private weak var startTimeView: UIView!
    private weak var startTimeLabel: UILabel!
    private weak var endTimeView: UIView!
    private weak var endTimeLabel: UILabel!

    private var feedbackGenerator: UIImpactFeedbackGenerator!

    init(targetEventView eventView: EventView) {

        super.init(frame: eventView.bounds)

        targetEventView = eventView
        event = eventView.event
        estimatedStartTime = eventView.event.start
        estimatedEndTime = eventView.event.end

        let snapshot = eventView.snapshotView(afterScreenUpdates: true)!
        addSubview(snapshot)

        let font = UIFont.systemFont(ofSize: 14)
        let space: CGFloat = 4

        let startTimeView = UIView()
        startTimeView.backgroundColor = targetEventView.themeColor
        addSubview(startTimeView)
        startTimeView.translatesAutoresizingMaskIntoConstraints = false
        startTimeView.trailingAnchor.constraint(equalTo: leadingAnchor, constant: -space).isActive = true
        startTimeView.centerYAnchor.constraint(equalTo: topAnchor).isActive = true
        self.startTimeView = startTimeView

        let startLabel = UILabel()
        startLabel.font = font
        startLabel.textColor = targetEventView.textColor
        startLabel.text = event.start.formattedString
        startTimeView.addSubview(startLabel)
        startLabel.translatesAutoresizingMaskIntoConstraints = false
        startLabel.topAnchor.constraint(equalTo: startTimeView.topAnchor, constant: space / 2).isActive = true
        startLabel.bottomAnchor.constraint(equalTo: startTimeView.bottomAnchor, constant: -space / 2).isActive = true
        startLabel.leadingAnchor.constraint(equalTo: startTimeView.leadingAnchor, constant: space).isActive = true
        startLabel.trailingAnchor.constraint(equalTo: startTimeView.trailingAnchor, constant: -space).isActive = true
        self.startTimeLabel = startLabel

        let endTimeView = UIView()
        endTimeView.backgroundColor = targetEventView.themeColor
        addSubview(endTimeView)
        endTimeView.translatesAutoresizingMaskIntoConstraints = false
        endTimeView.trailingAnchor.constraint(equalTo: leadingAnchor, constant: -space).isActive = true
        endTimeView.centerYAnchor.constraint(equalTo: bottomAnchor).isActive = true
        self.endTimeView = endTimeView

        let endLabel = UILabel()
        endLabel.font = font
        endLabel.textColor = targetEventView.textColor
        endLabel.text = event.end.formattedString
        endTimeView.addSubview(endLabel)
        endLabel.translatesAutoresizingMaskIntoConstraints = false
        endLabel.topAnchor.constraint(equalTo: endTimeView.topAnchor, constant: space / 2).isActive = true
        endLabel.bottomAnchor.constraint(equalTo: endTimeView.bottomAnchor, constant: -space / 2).isActive = true
        endLabel.leadingAnchor.constraint(equalTo: endTimeView.leadingAnchor, constant: space).isActive = true
        endLabel.trailingAnchor.constraint(equalTo: endTimeView.trailingAnchor, constant: -space).isActive = true
        self.endTimeLabel = endLabel

        let fitHeight = startLabel.sizeThatFits(CGSize(width: 100, height: 100)).height
        startTimeView.layer.cornerRadius = (fitHeight + space) / 2
        endTimeView.layer.cornerRadius = (fitHeight + space) / 2

        layer.masksToBounds = false
        layer.shadowOffset = .zero
        layer.shadowRadius = 4
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        layer.rasterizationScale = UIScreen.main.scale
        layer.shouldRasterize = true

        feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        feedbackGenerator.prepare()
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }


    func updateEstimatedTime(start: Time, end: Time) {

        let oldStartTime = estimatedStartTime
        let oldEndTime = estimatedEndTime

        estimatedStartTime = start
        estimatedEndTime = end

        startTimeLabel.text = start.formattedString
        endTimeLabel.text = end.formattedString

        if oldStartTime != estimatedStartTime || oldEndTime != estimatedEndTime {
            feedbackGenerator.impactOccurred()
        }
    }
}
