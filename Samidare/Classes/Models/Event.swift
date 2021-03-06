//
//  Event.swift
//  Samidare
//
//  Created by Keisuke Kawamura on 2018/03/25.
//  Copyright (c) 2018 Keisuke Kawamura. All rights reserved.

import Foundation

public struct Event {
    public var title: String?
    public var time: ClosedRange<Date>
    public var start: Date { return time.lowerBound }
    public var end: Date { return time.upperBound }
    public var durationInSeconds: Int { return time.durationInSeconds }

    public var color: UIColor
    public var isEditable: Bool
    public var source: Any?

    public init(title: String? = nil, time: ClosedRange<Date>, color: UIColor = .cyan, isEditable: Bool = true, source: Any? = nil) {
        self.title = title
        self.time = time
        self.color = color
        self.isEditable = isEditable
        self.source = source
    }
}
