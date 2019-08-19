//
//  UIView+.swift
//  Samidare
//
//  Created by Keisuke Kawamura on 2019/07/22.
//

import UIKit

internal extension UIView {
    func activateFitFrameConstarintsToSuperview() {
        guard let superview = self.superview else { fatalError() }
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            leftAnchor.constraint(equalTo: superview.leftAnchor),
            topAnchor.constraint(equalTo: superview.topAnchor),
            rightAnchor.constraint(equalTo: superview.rightAnchor),
            bottomAnchor.constraint(equalTo: superview.bottomAnchor)
        ])
    }
}
