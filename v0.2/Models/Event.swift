//
//  Event.swift
//  Samidare
//
//  Created by Keisuke Kawamura on 2018/03/25.
//  Copyright (c) 2018 Keisuke Kawamura. All rights reserved.

import Foundation

public struct Event {
    public var start: Date
    public var end: Date

    public var durationInSeconds: Int {
        return (start ... end).durationInSeconds
    }

    public var isEditable: Bool
    public var source: Any?

    public init(start: Date, end: Date, isEditable: Bool = true, source: Any? = nil) {
        guard start < end else { fatalError("🙅‍♀️ start >= end") }
        self.start = start
        self.end = end
        self.isEditable = isEditable
        self.source = source
    }
}
