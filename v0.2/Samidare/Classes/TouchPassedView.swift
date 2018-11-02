//
//  TouchPassedView.swift
//  Samidare
//
//  Created by Keisuke Kawamura on 2018/11/03.
//

import UIKit

internal class TouchPassedView: UIView {

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        if hitView == self { return nil }
        return hitView
    }
}
