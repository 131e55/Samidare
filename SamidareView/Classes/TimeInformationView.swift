//
//  TimeInformationView.swift
//  SamidareView
//
//  Created by Keisuke Kawamura on 2018/04/11.
//

import UIKit


protocol TimeInformationViewLayoutDelegate: class {

    func numberOfRows(in timeInformationView: TimeInformationView) -> Int
    func height(forRowAt row: Int, in timeInformationView: TimeInformationView) -> CGFloat
    func cell(forRowAt row: Int, in timeInformationView: TimeInformationView) -> TimeInformationCell
}


class TimeInformationView: UIView {

    weak var layoutDelegate: TimeInformationViewLayoutDelegate?

    private(set) weak var scrollView: UIScrollView!
    private weak var contentView: UIView!
    private weak var stackView: UIStackView!
    private var contentViewHeightConstraint: NSLayoutConstraint!

    private(set) var numberOfRows: Int = 0

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
        scrollView.isScrollEnabled = false
        addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        self.scrollView = scrollView

        let contentView = UIView()
        contentView.backgroundColor = .clear
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentViewHeightConstraint = contentView.heightAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: widthAnchor),
            contentViewHeightConstraint
        ])
        self.contentView = contentView

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 0
        contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
        self.stackView = stackView
    }

    func reload() {

        layoutContentView()
        reloadStackView()
    }

    private func layoutContentView() {

        guard let delegate = layoutDelegate else { return }

        numberOfRows = delegate.numberOfRows(in: self)

        var contentHeight: CGFloat = 0

        for row in 0 ..< numberOfRows {
            contentHeight += delegate.height(forRowAt: row, in: self)
        }

        contentViewHeightConstraint.constant = contentHeight
    }

    private func reloadStackView() {

        guard let delegate = layoutDelegate else { return }

        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for row in 0 ..< numberOfRows {

            let height = delegate.height(forRowAt: row, in: self)
            let cell = delegate.cell(forRowAt: row, in: self)
            cell.translatesAutoresizingMaskIntoConstraints = false
            cell.heightAnchor.constraint(equalToConstant: height).isActive = true
            stackView.addArrangedSubview(cell)
        }
    }
}
