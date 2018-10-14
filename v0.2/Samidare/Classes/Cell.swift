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
    internal var indexPath: IndexPath!

    open func configure(event: Event) {
        self.event = event
    }
}
