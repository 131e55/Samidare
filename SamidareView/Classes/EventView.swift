//
//  EventView.swift
//  SamidareView
//
//  Created by Keisuke Kawamura on 2018/03/26.
//

import UIKit

class EventView: UIView {

    private(set) var event: Event!

    init(event: Event) {

        super.init(frame: .zero)

        self.event = event

        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
