//
//  ViewController.swift
//  SamidareView
//
//  Created by Keisuke Kawamura on 03/22/2018.
//  Copyright (c) 2018 Keisuke Kawamura. All rights reserved.
//

import UIKit
import SamidareView

class ViewController: UIViewController {

    weak var samidareViewController: SamidareViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        samidareViewController = childViewControllers.first as! SamidareViewController
        samidareViewController.startTime = Time(hours: 2, minutes: 38)
        samidareViewController.endTime = Time(hours: 23, minutes: 43)
        samidareViewController.dataSource = self
        samidareViewController.reload()
    }
}

extension ViewController: SamidareViewDataSource {

    func numberOfColumns(in samidareView: SamidareView) -> Int {
        return 50
    }

    func events(in samidareView: SamidareView, inColumn column: Int) -> [Event] {

        let events = [
            Event(start: Time(hours: 8, minutes: 30), end: Time(hours: 17, minutes: 0))
        ]

        return events
    }
}
