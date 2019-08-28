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
        samidareView.registerEventTitleCell(UINib(nibName: "EventTitleCell", bundle: .main), forCellWithReuseIdentifier: "EventTitleCell")
        samidareView.didBeginEditingEventHandler = { cell in
            print("didBeginEditingEventHandler")
        }
        samidareView.didEditEventHandler = { cell in
            print(cell.event)
        }
        samidareView.didEndEditingEventHandler = { cell in
            print("didEndEditingEventHandler")
        }
        samidareView.willCreateEventHandler = { [weak self] event, indexPath in
            let cell = CustomCell()
            cell.configure(event: event)
            cell.applyCreatingStyle()
            return cell
        }
        samidareView.didUpdateCreatingEventHandler = { [weak self] cell in
            print(cell.event)
        }
    }
}

extension ViewController: SamidareViewDataSource {
    
    func timeRange(in samidareView: SamidareView) -> ClosedRange<Date> {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        return formatter.date(from: "2019/08/07 00:00")! ... formatter.date(from: "2019/08/09 06:30")!
    }
    
    func heightOfColumnTitle(in samidareView: SamidareView) -> CGFloat {
        return 44
    }
    
    func titleViewOfTimeColumn(in samidareView: SamidareView) -> UIView? {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "Time"
        return label
    }
    
    func titleViewOfFrozenColumn(at indexPath: IndexPath, in samidareView: SamidareView) -> UIView? {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "❄️\(indexPath.item)"
        return label
    }
    
    func titleCellOfEventColumn(at indexPath: IndexPath, in samidareView: SamidareView) -> UICollectionViewCell? {
        let cell = samidareView.dequeueReusableEventTitleCell(withReuseIdentifier: "EventTitleCell", for: indexPath) as! EventTitleCell
        cell.titleLabel.text = "\(indexPath)"
        return cell
    }
    
    func numberOfSections(in samidareView: SamidareView) -> Int {
        return 4
    }

    func numberOfColumns(in section: Int, in samidareView: SamidareView) -> Int {
        return 50
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
    
    func widthOfFrozenColumn(at indexPath: IndexPath, in samidareView: SamidareView) -> CGFloat {
        return 40
    }
    
    func numberOfFrozenColumns(in samidareView: SamidareView) -> Int {
        return 2
    }
    
    func frozenCells(at indexPath: IndexPath, in samidareView: SamidareView) -> [EventCell] {
        let events = sampleData[indexPath] ?? []
        let cells = events.map({ event -> EventCell in
            let cell = CustomCell()
            cell.backgroundColor = .green
            cell.configure(event: event)
            return cell
        })
        return cells
    }
}

final class SampleData {

    static func events(sections: Int, columns: Int) -> [IndexPath: [Event]] {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        let eventPatterns = [
            [
                Event(time: formatter.date(from: "2019/08/07 00:00")! ... formatter.date(from: "2019/08/07 06:00")!, isEditable: true, source: nil),
                Event(time: formatter.date(from: "2019/08/07 10:00")! ... formatter.date(from: "2019/08/07 22:00")!, isEditable: true, source: nil),
            ],
            [
                Event(time: formatter.date(from: "2019/08/07 04:30")! ... formatter.date(from: "2019/08/07 06:00")!, isEditable: true, source: nil),
                Event(time: formatter.date(from: "2019/08/07 08:00")! ... formatter.date(from: "2019/08/07 18:00")!, isEditable: true, source: nil),
            ],
            [
                Event(time: formatter.date(from: "2019/08/07 19:30")! ... formatter.date(from: "2019/08/08 03:00")!, isEditable: true, source: nil),
            ],
            [
                Event(time: formatter.date(from: "2019/08/07 00:30")! ... formatter.date(from: "2019/08/07 10:20")!, isEditable: true, source: nil),
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
