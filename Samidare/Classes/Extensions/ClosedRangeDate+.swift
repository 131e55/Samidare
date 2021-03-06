//
//  MinuteUnit.swift
//  Samidare
//
//  Created by Keisuke Kawamura on 2019/07/12.
//  Copyright (c) 2019 Keisuke Kawamura. All rights reserved.

import Foundation

extension ClosedRange where Bound == Date {
    var durationInSeconds: Int {
        return Int(upperBound.timeIntervalSinceReferenceDate - lowerBound.timeIntervalSinceReferenceDate)
    }
    
    var roundedDurationInMinutes: Int {
        let seconds = durationInSeconds
        let flooredMinutes = seconds / 60
        let roundedMinutes = flooredMinutes + (flooredMinutes % 60 >= 30 ? 1 : 0)
        return roundedMinutes
    }

    var ceilingDurationInMinutes: Int {
        let seconds = durationInSeconds
        let flooredMinutes = seconds / 60
        let ceilingMinutes = flooredMinutes + (seconds % 60 != 0 ? 0 : 1)
        return ceilingMinutes
    }
}
