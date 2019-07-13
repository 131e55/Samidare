//
//  String+.swift
//  Samidare
//
//  Created by Keisuke Kawamura on 2019/07/13.
//

import Foundation

internal extension String {
    static func timeText(date: Date) -> String {
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        return String(format: "%02d:%02d", arguments: [components.hour!, components.minute!])
    }
}
