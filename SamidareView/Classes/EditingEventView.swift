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
    let originalEvent: Event

    private(set) var startTimeInEditing: Time!
    private(set) var endTimeInEditing: Time!

    private weak var startTimeView: UIView!
    private weak var startTimeLabel: UILabel!
    private weak var endTimeView: UIView!
    private weak var endTimeLabel: UILabel!

    private(set) weak var topMarkArea: UIView!

    static let preferredTimeViewWidth: CGFloat = 44
    static let preferredTimeViewHeight: CGFloat = 18
    static let preferredTimeViewSpace: CGFloat = 4

    private var feedbackGenerator: UIImpactFeedbackGenerator!

    init(targetEventView eventView: EventView, isTimeLabelRightSide: Bool = false) {

        targetEventView = eventView
        originalEvent = eventView.event

        super.init(frame: eventView.bounds)

        startTimeInEditing = eventView.event.start
        endTimeInEditing = eventView.event.end

        let font = UIFont.systemFont(ofSize: 13)
        let themeColor = targetEventView.themeColor
        let textColor = targetEventView.textColor
        let timeViewWidth = EditingEventView.preferredTimeViewWidth
        let timeViewHeight = EditingEventView.preferredTimeViewHeight
        let timeViewSpace = EditingEventView.preferredTimeViewSpace

        layer.cornerRadius = 4

        let backgroundView = UIView()
        backgroundView.backgroundColor = themeColor
        backgroundView.layer.borderWidth = 1
        backgroundView.layer.borderColor = UIColor.white.cgColor
        backgroundView.layer.masksToBounds = true
        backgroundView.layer.cornerRadius = layer.cornerRadius
        addSubview(backgroundView)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true

        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 13)
        titleLabel.textAlignment = .center
        titleLabel.text = originalEvent.title
        titleLabel.textColor = textColor
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 4).isActive = true

        let startTimeView = UIView()
        startTimeView.backgroundColor = themeColor.withAlphaComponent(0.9)
        startTimeView.layer.borderWidth = 1
        startTimeView.layer.borderColor = UIColor.white.cgColor
        addSubview(startTimeView)
        startTimeView.translatesAutoresizingMaskIntoConstraints = false
        startTimeView.centerYAnchor.constraint(equalTo: topAnchor).isActive = true
        startTimeView.widthAnchor.constraint(equalToConstant: timeViewWidth).isActive = true
        startTimeView.heightAnchor.constraint(equalToConstant: timeViewHeight).isActive = true
        startTimeView.layer.cornerRadius = timeViewHeight / 2

        if isTimeLabelRightSide {
            startTimeView.leadingAnchor.constraint(equalTo: trailingAnchor, constant: timeViewSpace).isActive = true
        } else {
            startTimeView.trailingAnchor.constraint(equalTo: leadingAnchor, constant: -timeViewSpace).isActive = true
        }

        self.startTimeView = startTimeView

        let startLabel = UILabel()
        startLabel.font = font
        startLabel.textColor = textColor
        startLabel.text = originalEvent.start.formattedString
        startTimeView.addSubview(startLabel)
        startLabel.translatesAutoresizingMaskIntoConstraints = false
        startLabel.centerYAnchor.constraint(equalTo: startTimeView.centerYAnchor).isActive = true
        startLabel.centerXAnchor.constraint(equalTo: startTimeView.centerXAnchor).isActive = true
        self.startTimeLabel = startLabel

        let endTimeView = UIView()
        endTimeView.backgroundColor = themeColor.withAlphaComponent(0.9)
        endTimeView.layer.borderWidth = 1
        endTimeView.layer.borderColor = UIColor.white.cgColor
        addSubview(endTimeView)
        endTimeView.translatesAutoresizingMaskIntoConstraints = false
        endTimeView.centerYAnchor.constraint(equalTo: bottomAnchor).isActive = true
        endTimeView.widthAnchor.constraint(equalToConstant: timeViewWidth).isActive = true
        endTimeView.heightAnchor.constraint(equalToConstant: timeViewHeight).isActive = true
        endTimeView.layer.cornerRadius = timeViewHeight / 2

        if isTimeLabelRightSide {
            endTimeView.leadingAnchor.constraint(equalTo: trailingAnchor, constant: timeViewSpace).isActive = true
        } else {
            endTimeView.trailingAnchor.constraint(equalTo: leadingAnchor, constant: -timeViewSpace).isActive = true
        }

        self.endTimeView = endTimeView

        let endLabel = UILabel()
        endLabel.font = font
        endLabel.textColor = textColor
        endLabel.text = originalEvent.end.formattedString
        endTimeView.addSubview(endLabel)
        endLabel.translatesAutoresizingMaskIntoConstraints = false
        endLabel.centerYAnchor.constraint(equalTo: endTimeView.centerYAnchor).isActive = true
        endLabel.centerXAnchor.constraint(equalTo: endTimeView.centerXAnchor).isActive = true
        self.endTimeLabel = endLabel

        let topMarkArea = UIView()
        topMarkArea.backgroundColor = .red
        addSubview(topMarkArea)
        topMarkArea.translatesAutoresizingMaskIntoConstraints = false
        topMarkArea.centerYAnchor.constraint(equalTo: topAnchor).isActive = true
        topMarkArea.widthAnchor.constraint(equalToConstant: 44).isActive = true
        topMarkArea.heightAnchor.constraint(equalToConstant: 200).isActive = true
        topMarkArea.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        self.topMarkArea = topMarkArea

        let topMark = UIView()
        topMark.backgroundColor = themeColor
        topMarkArea.addSubview(topMark)
        topMark.translatesAutoresizingMaskIntoConstraints = false
        topMark.centerYAnchor.constraint(equalTo: topAnchor).isActive = true
        topMark.widthAnchor.constraint(equalToConstant: 12).isActive = true
        topMark.heightAnchor.constraint(equalToConstant: 12).isActive = true
        topMark.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4).isActive = true
        topMark.layer.cornerRadius = 6
        topMark.layer.borderColor = UIColor.white.cgColor
        topMark.layer.borderWidth = 1

        feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        feedbackGenerator.prepare()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let black = UIColor.black.cgColor
        layer.drawBorderShadow(borderWidth: 1, shadowRadius: 3, shadowOpacity: 0.5, shadowColor: black)
        startTimeView.layer.drawBorderShadow(borderWidth: 1, shadowRadius: 3, shadowOpacity: 0.5, shadowColor: black)
        endTimeView.layer.drawBorderShadow(borderWidth: 1, shadowRadius: 3, shadowOpacity: 0.5, shadowColor: black)
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func updateTimesInEditing(start: Time, end: Time) {

        let oldStartTime = startTimeInEditing
        let oldEndTime = endTimeInEditing

        startTimeInEditing = start
        endTimeInEditing = end

        startTimeLabel.text = start.formattedString
        endTimeLabel.text = end.formattedString

        if oldStartTime != startTimeInEditing || oldEndTime != endTimeInEditing {
            feedbackGenerator.impactOccurred()
        }
    }
}
