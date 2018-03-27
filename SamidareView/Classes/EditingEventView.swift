//
//  EditingEventView.swift
//  SamidareView
//
//  Created by Keisuke Kawamura on 2018/03/27.
//

import UIKit


class EditingEventView: UIView {

    private(set) var event: Event!

    init(sourceEventView eventView: EventView) {

        super.init(frame: eventView.bounds)

        event = eventView.event

        let snapshot = eventView.snapshotView(afterScreenUpdates: true)!
        addSubview(snapshot)

        layer.masksToBounds = false
        layer.shadowOffset = .zero
        layer.shadowRadius = 8
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        layer.rasterizationScale = UIScreen.main.scale
        layer.shouldRasterize = true
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
