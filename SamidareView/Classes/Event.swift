//
//  Event.swift
//  SamidareView
//
//  Created by Keisuke Kawamura on 2018/03/25.
//

import Foundation

public struct Event {

    public var id: Int? = nil
    public var start: Time
    public var end: Time
    public var title: String? = nil

    public init(id: Int? = nil, start: Time, end: Time, title: String? = nil) {

        self.id = id
        self.start = start
        self.end = end
        self.title = title
    }
}
