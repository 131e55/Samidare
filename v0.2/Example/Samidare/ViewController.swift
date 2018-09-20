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

    override func viewDidLoad() {
        super.viewDidLoad()
        samidareView.dataSource = self
    }
}

extension ViewController: SamidareViewDataSource {
    func numberOfSections(in samidareView: SamidareView) -> Int {
        return 2
    }

    func numberOfColumns(inSection: Int, in samidareView: SamidareView) -> Int {
        return 25
    }

    func cells(at indexPath: IndexPath, in samidareView: SamidareView) -> [Cell] {
        let events = SampleData.events[indexPath] ?? []
        let cells = events.map({ event -> Cell in
            let cell = Cell()
            cell.configure(event: event)
            return cell
        })
        return cells
    }
}

final class SampleData {
    static let events: [IndexPath: [Event]] = [
        IndexPath(column: 0, section: 0): [
            Event(start: Time(hours: 1, minutes: 30), end: Time(hours: 7, minutes: 45), isEditable: true),
            Event(start: Time(hours: 9, minutes: 0), end: Time(hours: 15, minutes: 35), isEditable: true)
        ]
    ]
}
