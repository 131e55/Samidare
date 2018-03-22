//
//  SamidareViewController.swift
//  SamidareView
//
//  Created by Keisuke Kawamura on 2018/03/22.
//

import UIKit


open class SamidareViewController: UIViewController {

    public var timeUnit = 10
    public var startTime = Time(hour: 1, minute: 30)
    public var endTime = Time(hour: 23, minute: 40)
    public var heightPerMinute: CGFloat = 1
    public var timeLabelWidth: CGFloat = 64

    private weak var samidareView: SamidareView!

    open override func viewDidLoad() {

        super.viewDidLoad()

        setupSamidareView()

        view.backgroundColor = .red
        samidareView.backgroundColor = .cyan
    }

    private func setupSamidareView() {

        let samidareView = SamidareView()
        view.addSubview(samidareView)
        samidareView.translatesAutoresizingMaskIntoConstraints = false
        samidareView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        samidareView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        samidareView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        samidareView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        self.samidareView = samidareView

        let totalMinutes = Time.calcTotalMinutes(from: startTime, to: endTime)
        samidareView.contentHeight = heightPerMinute * CGFloat(totalMinutes)

        let floorStartTime = Time(hour: startTime.hour, minute: 0)
        let ceilEndTime = endTime.minute > 0 ? Time(hour: endTime.hour + 1, minute: 0) : endTime
        samidareView.numberOfRows = ceilEndTime.hour - floorStartTime.hour + 1
        print(floorStartTime)
        print(ceilEndTime)
    }
}

open class SamidareView: UIScrollView {

    private weak var contentView: UIView!
    private weak var contentStackView: UIStackView!
    private var contentViewHeightConstraint: NSLayoutConstraint!

    public var timeLabelWidth: CGFloat = 64

    public var contentHeight: CGFloat = 0 {
        didSet { layoutContentView() }
    }

    public var numberOfRows: Int = 0 {
        didSet { reloadContentStackView() }
    }

    public var heightForRow: CGFloat = 0 {
        didSet { reloadContentStackView() }
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

        let contentView = UIView(frame: bounds)
        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        contentView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        contentViewHeightConstraint = contentView.heightAnchor.constraint(equalToConstant: contentHeight)
        contentViewHeightConstraint.isActive = true
        self.contentView = contentView

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        self.contentStackView = stackView

        reloadContentStackView()
    }

    private func layoutContentView() {

        contentViewHeightConstraint.constant = contentHeight
        layoutIfNeeded()
    }

    private func reloadContentStackView() {

        for view in contentStackView.arrangedSubviews {
            view.removeFromSuperview()
        }

        for row in 0 ..< numberOfRows {
            let view = UIView()
            view.backgroundColor = [.red, .green, .blue][row % 3]
            contentStackView.addArrangedSubview(view)
        }
    }
}

