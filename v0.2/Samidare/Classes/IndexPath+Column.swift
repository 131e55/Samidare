//
//  IndexPath+Column.swift
//  Samidare
//
//  Created by Keisuke Kawamura on 2018/09/20.
//  Copyright (c) 2018 Keisuke Kawamura. All rights reserved.
//

import Foundation

public extension IndexPath {
    var column: Int {
        return item
    }

    init(column: Int, section: Int) {
        self.init(item: column, section: section)
    }
}
