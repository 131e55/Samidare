//
//  TimeRange.swift
//  SamidareView
//
//  Created by Keisuke Kawamura on 2018/03/26.
//

import Foundation

// TODO: - validate [end - start >= minInterval]

public struct TimeRange {

    public var start: Time = Time(hours: 0, minutes: 0) {
        didSet { roundTimes() }
    }
    public var end: Time = Time(hours: 24, minutes: 0) {
        didSet { roundTimes() }
    }

    /// Minimum interval of minutes
    public var minInterval: Int = 15 {
        didSet {
            minInterval = min(max(minInterval, 0), 60)
            roundTimes()
        }
    }

    public var numberOfIntervals: Int {
        return (end.totalMinutes - start.totalMinutes) / minInterval
    }

    public init(start: Time, end: Time, minInterval: Int = 15) {

        self.start = start
        self.end = end
        self.minInterval = min(max(minInterval, 0), 60)
        roundTimes()
    }

    private mutating func roundTimes() {

        // floor
        var modulo = start.minutes % minInterval
        if modulo > 0 {
            start.minutes -= modulo
        }

        // ceil
        modulo = end.minutes % minInterval
        if modulo > 0 {
            end.minutes -= modulo
            end.minutes += minInterval
        }
    }
}
