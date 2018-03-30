//
//  Event.swift
//  SamidareView
//
//  Created by Keisuke Kawamura on 2018/03/25.
//

import Foundation

public struct Event {

    public var id: Int? = nil
    public var title: String? = nil
    public var start: Time
    public var end: Time
    public var icon: UIImage? = nil
    public var isEditable: Bool = true

    public init(id: Int? = nil, title: String? = nil, start: Time, end: Time, icon: UIImage? = nil, isEditable: Bool = true) {

        self.id = id
        self.title = title
        self.start = start
        self.end = end
        self.icon = icon
        self.isEditable = isEditable
    }
}
