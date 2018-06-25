//
//  EventView.swift
//  SamidareView
//
//  Created by Keisuke Kawamura on 2018/03/26.
//

import UIKit

open class EventView: UIView {

    public private(set) var event: Event

    public var themeColor: UIColor = .cyan {
        didSet {
            backgroundView.backgroundColor = themeColor
            backgroundViewInEditing.backgroundColor = themeColor.withAlphaComponent(0.85)
            startTimeView.backgroundColor = themeColor.withAlphaComponent(0.85)
            endTimeView.backgroundColor = themeColor.withAlphaComponent(0.85)
        }
    }

    public var isBorderStyle: Bool = false {
        didSet {
            if isBorderStyle {
                backgroundView.layer.borderWidth = 1
                backgroundView.layer.borderColor = themeColor.cgColor
                backgroundView.backgroundColor = borderFillColor
                backgroundViewInEditing.layer.borderWidth = 1
                backgroundViewInEditing.layer.borderColor = themeColor.withAlphaComponent(0.85).cgColor
                backgroundViewInEditing.backgroundColor = borderFillColor.withAlphaComponent(0.85)
            } else {
                backgroundView.layer.borderWidth = 0
                backgroundView.layer.borderColor = nil
                backgroundView.backgroundColor = themeColor
                backgroundViewInEditing.layer.borderWidth = 0
                backgroundViewInEditing.layer.borderColor = nil
                backgroundViewInEditing.backgroundColor = themeColor.withAlphaComponent(0.85)
            }
        }
    }

    public var borderFillColor: UIColor = .white {
        didSet {
            if isBorderStyle {
                backgroundView.backgroundColor = borderFillColor
                backgroundViewInEditing.backgroundColor = borderFillColor.withAlphaComponent(0.85)
            }
        }
    }

    public var textColor: UIColor = .black {
        didSet {
            titleLabel.textColor = textColor
            startTimeLabel.textColor = textColor
            endTimeLabel.textColor = textColor
        }
    }
    public var iconHeight: CGFloat = 20 {
        didSet {
            iconImageViewHeightConstraint.constant = iconHeight
        }
    }
    public var cornerRadius: CGFloat = 4 {
        didSet {
            backgroundView.layer.cornerRadius = cornerRadius
            backgroundViewInEditing.layer.cornerRadius = cornerRadius
        }
    }

    public private(set) var isEditing = false {
        didSet {
            backgroundView.isHidden = isEditing
            backgroundViewInEditing.isHidden = !isEditing
            editingTimeView.isHidden = !isEditing
        }
    }

    internal var isTimeViewsRightSide: Bool = false {
        didSet {
            editingTimeViewLeadingConstraintForRightSide.isActive = isTimeViewsRightSide
        }
    }

    @IBOutlet private weak var snapshotTargetView: UIView!
    @IBOutlet private(set) weak var backgroundView: UIView!
    @IBOutlet private(set) weak var iconImageView: UIImageView!
    @IBOutlet private weak var iconImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet public private(set) weak var titleLabel: UILabel!

    // For editing
    @IBOutlet private weak var backgroundViewInEditing: UIView!
    @IBOutlet private(set) weak var editingTimeView: UIView!
    @IBOutlet private var editingTimeViewLeadingConstraintForRightSide: NSLayoutConstraint!
    @IBOutlet private weak var startTimeView: UIView!
    @IBOutlet private weak var startTimeLabel: UILabel!
    @IBOutlet private weak var endTimeView: UIView!
    @IBOutlet private weak var endTimeLabel: UILabel!
    private(set) var startTimeInEditing: Time!
    private(set) var endTimeInEditing: Time!
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)

    public init(event: Event, isTimeViewsRightSide: Bool = false) {

        self.event = event

        super.init(frame: .zero)

        backgroundColor = .clear
        clipsToBounds = false

        let view = Bundle(for: type(of: self)).loadNibNamed("EventView", owner: self, options: nil)!.first as! UIView
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: topAnchor),
            view.bottomAnchor.constraint(equalTo: bottomAnchor),
            view.leadingAnchor.constraint(equalTo: leadingAnchor),
            view.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        backgroundView.backgroundColor = themeColor
        backgroundView.layer.cornerRadius = cornerRadius
        backgroundViewInEditing.backgroundColor = themeColor
        backgroundViewInEditing.layer.borderColor = UIColor.white.cgColor
        backgroundViewInEditing.layer.cornerRadius = cornerRadius
        startTimeView.layer.borderColor = UIColor.white.cgColor
        endTimeView.layer.borderColor = UIColor.white.cgColor
        let black = UIColor.black.cgColor
        startTimeView.layer.drawBorderShadow(borderWidth: 1, shadowRadius: 3, shadowOpacity: 0.5, shadowColor: black)
        endTimeView.layer.drawBorderShadow(borderWidth: 1, shadowRadius: 3, shadowOpacity: 0.5, shadowColor: black)

        // Default is Left side
        editingTimeViewLeadingConstraintForRightSide.isActive = false

        if let image = event.icon {
            iconImageView.image = image
        } else {
            iconImageView.isHidden = true
        }

        titleLabel.text = event.title
        titleLabel.textColor = textColor

        updateTimesInEditing(start: event.start, end: event.end)
        endEditing()
    }

    required public init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    open override func layoutSubviews() {
        super.layoutSubviews()

        titleLabel.isHidden = bounds.height <= iconImageViewHeightConstraint.constant

        drawShadowIfNeeded()
    }

    private func drawShadowIfNeeded() {
        guard isEditing else { return }

        let black = UIColor.black.cgColor
        layer.masksToBounds = false
        clipsToBounds = false
        layer.drawBorderShadow(borderWidth: 1, shadowRadius: 3, shadowOpacity: 0.5, shadowColor: black)
    }


    // MARK: - Editing

    func beginEditing() {

        isEditing = true
        drawShadowIfNeeded()
        feedbackGenerator.prepare()
    }

    func endEditing() {

        layer.shadowOpacity = 0
        isEditing = false
    }

    func updateTimesInEditing(start: Time, end: Time) {

        let oldStart = startTimeInEditing
        let oldEnd = endTimeInEditing

        startTimeInEditing = start
        endTimeInEditing = end

        startTimeLabel.text = start.formattedString
        endTimeLabel.text = end.formattedString

        if let oldStart = oldStart, let oldEnd = oldEnd,
            oldStart != startTimeInEditing || oldEnd != endTimeInEditing {
            feedbackGenerator.impactOccurred()
        }
    }

    func applyTimesInEditing() {

        event.start = startTimeInEditing
        event.end = endTimeInEditing
    }

    /// snapshotView excluded editing views
    func snapshotView() -> UIView {

        let isHidden = backgroundView.isHidden
        backgroundView.isHidden = false
        let snapshot = snapshotTargetView.snapshotView(afterScreenUpdates: true)!
        backgroundView.isHidden = isHidden

        return snapshot
    }
}

extension EventView {

    static func createMarkAreaView(color: UIColor, isTop: Bool) -> UIView {

        let markArea = UIView()
        markArea.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            markArea.widthAnchor.constraint(equalToConstant: 40),
            markArea.heightAnchor.constraint(equalToConstant: 40)
        ])

        let markView = UIView()
        markView.backgroundColor = color
        markArea.addSubview(markView)
        markView.translatesAutoresizingMaskIntoConstraints = false
        let leadingOrTrainingConstraint = isTop
            ? markView.trailingAnchor.constraint(equalTo: markArea.trailingAnchor, constant: -4)
            : markView.leadingAnchor.constraint(equalTo: markArea.leadingAnchor, constant: 4)
        NSLayoutConstraint.activate([
            markView.widthAnchor.constraint(equalToConstant: 12),
            markView.heightAnchor.constraint(equalToConstant: 12),
            markView.centerYAnchor.constraint(equalTo: markArea.centerYAnchor),
            leadingOrTrainingConstraint
        ])
        markView.layer.cornerRadius = 6
        markView.layer.borderColor = UIColor.white.cgColor
        markView.layer.borderWidth = 1

        return markArea
    }
}
