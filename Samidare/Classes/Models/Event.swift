//
//  Event.swift
//  Samidare
//
//  Created by Keisuke Kawamura on 2018/03/25.
//  Copyright (c) 2018 Keisuke Kawamura. All rights reserved.

import Foundation

public struct Event {
    public var time: ClosedRange<Date>
    public var start: Date { return time.lowerBound }
    public var end: Date { return time.upperBound }
    public var durationInSeconds: Int { return time.durationInSeconds }

    public var isEditable: Bool
    public var source: Any?

    public init(time: ClosedRange<Date>, isEditable: Bool = true, source: Any? = nil) {
        self.time = time
        self.isEditable = isEditable
        self.source = source
    }
}
