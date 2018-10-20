//
//  ReuseQueue.swift
//  Samidare
//
//  Created by Keisuke Kawamura on 2018/10/15.
//

import UIKit

extension SamidareView {

    final internal class ReusableCellQueue {

        typealias ReuseIdentifier = String

        private var nibs: [ReuseIdentifier: UINib] = [:]
        private var cells: [ReuseIdentifier: [EventCell]] = [:]

        internal func register(_ nib: UINib, forCellReuseIdentifier identifier: String) {
            nibs[identifier] = nib
        }

        internal func enqueue(_ cell: EventCell) {
            guard let reuseIdentifier = cell.reuseIdentifier else { return }
            var values = cells[reuseIdentifier] ?? []
            values.append(cell)
            cells[reuseIdentifier] = values
        }

        internal func dequeue<T: EventCell>(withReuseIdentifier identifier: String) -> T? {
            if cells[identifier]?.isEmpty == false {
                return cells[identifier]!.removeFirst() as? T
            }
            return nil
        }

        internal func create<T: EventCell>(withReuseIdentifier identifier: String) -> T {
            guard let nib = nibs[identifier] else {
                fatalError("[Samidare] Nib (identifier: \(identifier)) not registered")
            }
            guard let cell = nib.instantiate(withOwner: nil, options: nil).first as? EventCell else {
                fatalError("[Samidare] could not create a cell from Nib (identifier: \(identifier))")
            }
            cell.reuseIdentifier = identifier
            dprint(cell)
            return cell as! T
        }
    }
}
