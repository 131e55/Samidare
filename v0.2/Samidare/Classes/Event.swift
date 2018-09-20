//
//  Event.swift
//  Samidare
//
//  Created by Keisuke Kawamura on 2018/03/25.
//  Copyright (c) 2018 Keisuke Kawamura. All rights reserved.

import Foundation

public struct Event {
    public var id: Int?
    public var start: Time
    public var end: Time
    public var isEditable: Bool
    public var source: Any?

    public init(id: Int? = nil, start: Time, end: Time, isEditable: Bool = true, source: Any? = nil) {
        self.id = id
        self.start = start
        self.end = end
        self.isEditable = isEditable
        self.source = source
    }
}
