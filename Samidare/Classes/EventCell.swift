//
//  EventCell.swift
//  Samidare
//
//  Created by Keisuke Kawamura on 2018/09/20.
//  Copyright (c) 2018 Keisuke Kawamura. All rights reserved.
//

import UIKit

open class EventCell: UIView {

    internal static let willRemoveFromSuperviewNotification = Notification.Name("EventCellWillRemoveFromSuperviewNotification")
    internal static let didSetEventNotification = Notification.Name("EventCellDidSetEventNotification")

    private(set) public var event: Event = .init(time: Date() ... Date()) {
        didSet {
            NotificationCenter.default.post(name: EventCell.didSetEventNotification, object: self)
        }
    }
    
    public var editingColor: UIColor = .white

    /// Current indexPath in EventScrollView or nil If the cell not a subview of EventScrollView.
    public internal(set) var indexPath: IndexPath!

    internal var reuseIdentifier: String?

    deinit {
//        dprint("deinit")
    }

    open func configure(event: Event) {
        self.event = event
    }

    internal func snapshotView() -> UIView {
        let snapshot = snapshotView(afterScreenUpdates: true)!
        return snapshot
    }

    open override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)

        if newSuperview == nil {
            NotificationCenter.default.post(name: EventCell.willRemoveFromSuperviewNotification, object: self)
        }
    }
}
