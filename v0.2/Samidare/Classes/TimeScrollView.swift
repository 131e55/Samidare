//
//  TimeScrollView.swift
//  Samidare
//
//  Created by Keisuke Kawamura on 2018/09/22.
//  Copyright (c) 2018 Keisuke Kawamura. All rights reserved.
//

import UIKit

open class TimeScrollView: UIScrollView {

    public weak var dataSource: SamidareViewDataSource?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {

    }
}
