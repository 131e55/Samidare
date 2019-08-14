//
//  CustomCell.swift
//  Samidare_Example
//
//  Created by Keisuke Kawamura on 2018/10/15.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import Samidare

final class CustomCell: EventCell {

    @IBOutlet private weak var nameLabel: UILabel!

    override func configure(event: Event) {
        super.configure(event: event)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if superview != nil, let indexPath = indexPath {
            nameLabel.text = "\(indexPath)"
        }
    }
    
    override func didMoveToSuperview() {
        if superview != nil, let indexPath = indexPath, let nameLabel = nameLabel {
            nameLabel.text = "\(indexPath)"
        }
    }
    
    func applyCreatingStyle() {
        backgroundColor = .clear
        layer.borderColor = UIColor.blue.cgColor
        layer.borderWidth = 1
    }
}
