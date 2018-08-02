//
//  Event.swift
//  SamidareView
//
//  Created by Keisuke Kawamura on 2018/03/25.
//

import Foundation

public struct Event {

    public var id: Int?
    public var title: String?
    public var start: Time
    public var end: Time
    public var icon: UIImage?
    public var isEditable: Bool
    public var source: Any?

    public init(id: Int? = nil, title: String? = nil, start: Time, end: Time, icon: UIImage? = nil, isEditable: Bool = true, source: Any? = nil) {

        self.id = id
        self.title = title
        self.start = start
        self.end = end
        self.icon = icon
        self.isEditable = isEditable
        self.source = source
    }
}
