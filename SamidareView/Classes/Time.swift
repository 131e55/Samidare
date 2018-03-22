//
//  Time.swift
//  SamidareView
//
//  Created by Keisuke Kawamura on 2018/03/22.
//

import Foundation

public struct Time {

    public var hour: Int = 0 {
        didSet {
            hour = min(max(hour, 0), 24)
            if hour == 24 {
                minute = 0
            }
        }
    }

    public var minute: Int = 0 {
        didSet {
            let upper = hour == 24 ? 0 : 59
            minute = min(max(minute, 0), upper)
        }
    }

    public init(hour: Int, minute: Int) {
        setup(hour: hour, minute: minute)
    }

    private mutating func setup(hour h: Int, minute m: Int) {
        hour = h
        minute = m
    }

    static func calcTotalMinutes(from: Time, to: Time) -> Int {
        let fromMinutes = from.hour * 60 + from.minute
        let toMinutes = to.hour * 60 + to.minute
        let minutes = Int(abs(toMinutes - fromMinutes))
        return minutes
    }
}
