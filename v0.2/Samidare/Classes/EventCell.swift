//
//  EventCell.swift
//  Samidare
//
//  Created by Keisuke Kawamura on 2018/09/20.
//  Copyright (c) 2018 Keisuke Kawamura. All rights reserved.
//

import UIKit

open class EventCell: UIView {

    private(set) var event: Event!

    /// Current indexPath in EventScrollView or nil If the cell not a subview of EventScrollView.
    internal var indexPath: IndexPath!

    internal(set) var reuseIdentifier: String?

    open func configure(event: Event) {
        self.event = event
    }

    internal func snapshot() -> UIView {
        let snapshot = snapshotView(afterScreenUpdates: true)!
        return snapshot
    }
}
