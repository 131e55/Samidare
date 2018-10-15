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
    func numberOfSections(in samidareView: SamidareView) -> Int {
        return 4
    }

    func numberOfColumns(in section: Int, in samidareView: SamidareView) -> Int {
        return 50
    }

    func cells(at indexPath: IndexPath, in samidareView: SamidareView) -> [Cell] {
        let events = sampleData[indexPath] ?? []
        let cells = events.map({ event -> Cell in
            let cell = samidareView.dequeueCell(withReuseIdentifier: "CustomCell")
            cell.configure(event: event)
            cell.backgroundColor = .red
            return cell
        })
        return cells
    }
}

final class SampleData {

    static func events(sections: Int, columns: Int) -> [IndexPath: [Event]] {
        var events: [IndexPath: [Event]] = [:]
        var hours = 1
        for section in 0 ..< sections {
            for column in 0 ..< columns {
                let indexPath = IndexPath(column: column, section: section)
                events[indexPath] = [
                    Event(start: Time(hours: hours, minutes: 0), end: Time(hours: hours + 4, minutes: 0), isEditable: true),
                    Event(start: Time(hours: hours + 6, minutes: 0), end: Time(hours: hours + 10, minutes: 0), isEditable: true)
                ]
                hours += 1
                if hours > 24 {
                    hours = 1
                }
            }
        }
        return events
    }
}
