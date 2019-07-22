//
//  CreatingEventView.swift
//  Samidare
//
//  Created by Keisuke Kawamura on 2019/07/22.
//

import UIKit

internal final class CreatingEventView: TouchPassedView {
    private static let nib: UINib = UINib(nibName: "CreatingEventView", bundle: Bundle(for: CreatingEventView.self))

    private var cellInCreating: EventCell!
    
    init(cell: EventCell) {
        super.init(frame: .zero)
        self.cellInCreating = cell
    }
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
