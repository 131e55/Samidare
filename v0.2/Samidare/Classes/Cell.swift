//
//  Cell.swift
//  Samidare
//
//  Created by Keisuke Kawamura on 2018/09/20.
//  Copyright (c) 2018 Keisuke Kawamura. All rights reserved.
//

import UIKit

open class Cell: UIView {

    private(set) var event: Event!

    /// Current IndexPath in EventScrollView or nil If the cell not a subview of EventScrollView.
    internal var indexPath: IndexPath!

    internal(set) var reuseIdentifier: String?

    open func configure(event: Event) {
        self.event = event
    }
}
