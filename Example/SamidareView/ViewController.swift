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
        samidareViewController.view.backgroundColor = .groupTableViewBackground
        samidareViewController.dataSource = self
        samidareViewController.delegate = self
        samidareViewController.reload()
    }
}

extension ViewController: SamidareViewDataSource {

    func timeRange(in samidareView: SamidareView) -> TimeRange {

        return TimeRange(start:  Time(hours: 1, minutes: 40),
                         end: Time(hours: 23, minutes: 50),
                         minInterval: 10)
    }

    func numberOfColumns(in samidareView: SamidareView) -> Int {
        return 50
    }

    func events(in samidareView: SamidareView, inColumn column: Int) -> [Event] {

        let events = [
            [
                Event(start: Time(hours: 4, minutes: 30), end: Time(hours: 7, minutes: 45)),
                Event(start: Time(hours: 8, minutes: 0), end: Time(hours: 17, minutes: 0))
            ],
            [
                Event(start: Time(hours: 5, minutes: 15), end: Time(hours: 6, minutes: 45)),
                Event(start: Time(hours: 15, minutes: 0), end: Time(hours: 22, minutes: 15))
            ],
            [
                Event(start: Time(hours: 3, minutes: 45), end: Time(hours: 7, minutes: 45)),
                Event(start: Time(hours: 22, minutes: 0), end: Time(hours: 23, minutes: 15))
            ],
            [
                Event(start: Time(hours: 3, minutes: 30), end: Time(hours: 7, minutes: 45)),
                Event(start: Time(hours: 8, minutes: 45), end: Time(hours: 19, minutes: 30))
            ]
        ][column % 4]

        return events
    }
}

extension ViewController: SamidareViewDelegate {

    func widthForTimeColumn(in samidareView: SamidareView) -> CGFloat {
        return 50
    }

    func widthForEventColumn(in samidareView: SamidareView) -> CGFloat {
        return 44
    }

    func heightPerMinInterval(in samidareView: SamidareView) -> CGFloat {
        return 22
    }
}
