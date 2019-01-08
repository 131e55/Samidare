//
//  ViewController.swift
//  SamidareView
//
//  Created by Keisuke Kawamura on 03/22/2018.
//  Copyright (c) 2018 Keisuke Kawamura. All rights reserved.
//

import UIKit
import Samidare

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

        return TimeRange(start:  Time(hours: 1, minutes: 45),
                         end: Time(hours: 23, minutes: 15),
                         minInterval: 15)
    }

    func numberOfColumns(in samidareView: SamidareView) -> Int {
        return 50
    }

    func events(in samidareView: SamidareView, inColumn column: Int) -> [Event] {

        let events = [
            [
                Event(title: "テスト１", start: Time(hours: 1, minutes: 40), end: Time(hours: 7, minutes: 45)),
                Event(title: "テスト２", start: Time(hours: 8, minutes: 0), end: Time(hours: 17, minutes: 0))
            ],
            [
                Event(title: "cantEdit", start: Time(hours: 5, minutes: 15), end: Time(hours: 6, minutes: 45), isEditable: false),
                Event(title: "テスト４", start: Time(hours: 15, minutes: 0), end: Time(hours: 22, minutes: 15), icon: UIImage(named: "icon"))
            ],
            [
                Event(title: "テスト５", start: Time(hours: 3, minutes: 45), end: Time(hours: 7, minutes: 45)),
                Event(title: "テスト６", start: Time(hours: 22, minutes: 0), end: Time(hours: 23, minutes: 15))
            ],
            [
                Event(title: "テスト７", start: Time(hours: 3, minutes: 30), end: Time(hours: 7, minutes: 45)),
                Event(title: "テスト８", start: Time(hours: 8, minutes: 45), end: Time(hours: 19, minutes: 30))
            ],
            [
                Event(title: "テスト９", start: Time(hours: -1, minutes: 45), end: Time(hours: 14, minutes: 20)),
                Event(title: "テスト１０", start: Time(hours: 18, minutes: 30), end: Time(hours: 28, minutes: 15))
            ],
        ][column % 5]

        return events
    }
}

extension ViewController: SamidareViewDelegate {

    func widthForTimeColumn(in samidareView: SamidareView) -> CGFloat {
        return 44
    }

    func widthForEventColumn(in samidareView: SamidareView) -> CGFloat {
        return 44
    }

    func heightPerMinInterval(in samidareView: SamidareView) -> CGFloat {
        return 20
    }

    func eventView(in samidareView: SamidareView, inColumn column: Int, for event: Event) -> EventView {

        let view = EventView(event: event)
        view.themeColor = [.red, .green, .blue, .cyan, .magenta, .yellow][column % 6]
        view.textColor = [.white, .black, .white, .black, .white, .black][column % 6]
        view.cornerRadius = 4
        view.iconTintColor = view.textColor

        return view
    }

    func eventViewDidTap(in samidareView: SamidareView, eventView: EventView) {

        print("eventViewDidTap", eventView.event)
    }

    func eventDidEdit(in samidareView: SamidareView, newEvent: Event, oldEvent: Event) {

        print("oldEvent", oldEvent)
        print("newEvent", newEvent)
    }
}
