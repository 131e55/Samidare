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
        contentView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        contentViewHeightConstraint = contentView.heightAnchor.constraint(equalToConstant: 0)
        contentViewHeightConstraint.isActive = true
        self.contentView = contentView

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 0
        contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
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
