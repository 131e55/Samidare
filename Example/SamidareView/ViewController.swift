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
                Event(title: "テスト３", start: Time(hours: 5, minutes: 15), end: Time(hours: 6, minutes: 45)),
                Event(title: "テスト４", start: Time(hours: 15, minutes: 0), end: Time(hours: 22, minutes: 15))
            ],
            [
                Event(title: "テスト５", start: Time(hours: 3, minutes: 45), end: Time(hours: 7, minutes: 45)),
                Event(title: "テスト６", start: Time(hours: 22, minutes: 0), end: Time(hours: 23, minutes: 50))
            ],
            [
                Event(title: "テスト７", start: Time(hours: 3, minutes: 30), end: Time(hours: 7, minutes: 45)),
                Event(title: "テスト８", start: Time(hours: 8, minutes: 45), end: Time(hours: 19, minutes: 30))
            ]
        ][column % 4]

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

        let view = CustomEventView(event: event)
        view.themeColor = [.red, .green, .blue, .cyan, .magenta, .yellow][column % 6]
        view.textColor = [.white, .black, .white, .black, .white, .black][column % 6]
        
        return view
    }

    func eventDidEdit(in samidareView: SamidareView, newEvent: Event, oldEvent: Event) {

        print("oldEvent", oldEvent)
        print("newEvent", newEvent)
    }
}

// 廃止予定
class CustomEventView: EventView {

    override init(event: Event) {
        super.init(event: event)
//        layer.cornerRadius = 4
//
//        let label = UILabel()
//        label.text = "😻"
//        addSubview(label)
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
//        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
