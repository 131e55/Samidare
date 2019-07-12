//
//  ViewController.swift
//  Samidare
//
//  Created by Keisuke Kawamura on 09/20/2018.
//  Copyright (c) 2018 Keisuke Kawamura. All rights reserved.
//

import UIKit
import Samidare

final class ViewController: UIViewController {

    @IBOutlet private weak var samidareView: SamidareView!

    let sampleData = SampleData.events(sections: 4, columns: 50)

    override func viewDidLoad() {
        super.viewDidLoad()
        samidareView.dataSource = self
        samidareView.register(UINib(nibName: "CustomCell", bundle: .main), forCellReuseIndentifier: "CustomCell")
    }
}

extension ViewController: SamidareViewDataSource {
    
    func timeRange(in samidareView: SamidareView) -> ClosedRange<Date> {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        return formatter.date(from: "2019/08/07 00:00")! ... formatter.date(from: "2019/08/08 02:00")!
    }

    func numberOfSections(in samidareView: SamidareView) -> Int {
        return 4
    }

    func numberOfColumns(in section: Int, in samidareView: SamidareView) -> Int {
        return 50
    }
    
    func heightPerMinInterval(in samidareView: SamidareView) -> CGFloat {
        return 16
    }

    func cells(at indexPath: IndexPath, in samidareView: SamidareView) -> [EventCell] {
        let events = sampleData[indexPath] ?? []
        let cells = events.map({ event -> EventCell in
            let cell = samidareView.dequeueCell(withReuseIdentifier: "CustomCell")
            cell.configure(event: event)
            return cell
        })
        return cells
    }
}

final class SampleData {

    static func events(sections: Int, columns: Int) -> [IndexPath: [Event]] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        let eventPatterns = [
            [
                Event(start: formatter.date(from: "2019/08/07 00:00")!, end: formatter.date(from: "2019/08/07 06:00")!, isEditable: true, source: nil),
                Event(start: formatter.date(from: "2019/08/07 10:00")!, end: formatter.date(from: "2019/08/07 22:00")!, isEditable: true, source: nil),
            ],
            [
                Event(start: formatter.date(from: "2019/08/07 04:30")!, end: formatter.date(from: "2019/08/07 06:00")!, isEditable: true, source: nil),
                Event(start: formatter.date(from: "2019/08/07 08:00")!, end: formatter.date(from: "2019/08/07 18:00")!, isEditable: true, source: nil),
            ],
            [
                Event(start: formatter.date(from: "2019/08/07 19:30")!, end: formatter.date(from: "2019/08/08 03:00")!, isEditable: true, source: nil),
            ],
            [
                Event(start: formatter.date(from: "2019/08/06 22:30")!, end: formatter.date(from: "2019/08/07 10:20")!, isEditable: true, source: nil),
            ]
        ]
        
        var events: [IndexPath: [Event]] = [:]
        for section in 0 ..< sections {
            for column in 0 ..< columns {
                let indexPath = IndexPath(column: column, section: section)
                events[indexPath] = eventPatterns[Int.random(in: 0 ..< eventPatterns.count)]
            }
        }
        return events
    }
}
