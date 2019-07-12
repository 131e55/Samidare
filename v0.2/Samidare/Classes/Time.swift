//
//  Time.swift
//  Samidare
//
//  Created by Keisuke Kawamura on 2018/03/22.
//  Copyright (c) 2018 Keisuke Kawamura. All rights reserved.
//

import Foundation

public struct TimeText {
    
    private(set) var body: String
    
    init(date: Date) {
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        body = String(format: "%02d:%02d", arguments: [components.hour!, components.minute!])
    }
}


public struct Time {

    public static var zero: Time { return Time(hours: 0, minutes: 0) }

    /// Number of hours. (Range: 0 ... n)
    public var hours: Int = 0 {
        didSet {
            hours = max(hours, 0)
        }
    }

    /// Number of minutes. (Range: 0 ... 59)
    public var minutes: Int = 0 {
        didSet {
            let additionalHours = minutes / 60
            if additionalHours > 0 {
                hours += additionalHours
            }
            minutes = max(minutes % 60, 0)
        }
    }

    public var totalMinutes: Int {
        return hours * 60 + minutes
    }

    public var formattedString: String {
        return String(format: "%02d:%02d", arguments: [hours, minutes])
    }

    public var floored: Time {
        return Time(hours: hours, minutes: 0)
    }

    public var ceiled: Time {
        if minutes == 0 {
            return self
        }
        return Time(hours: hours + 1, minutes: 0)
    }

    public init(hours: Int, minutes: Int) {
        // to call didSet
        initialize(hours: hours, minutes: minutes)
    }
    
    public init(minutes: Int) {
        // to call didSet
        initialize(hours: 0, minutes: minutes)
    }

    public init(from date: Date, calendar: Calendar = Calendar(identifier: .gregorian)) {
        let hours = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        self.init(hours: hours, minutes: minutes)
    }

    private mutating func initialize(hours: Int, minutes: Int) {
        self.hours = hours
        self.minutes = minutes
    }
}

extension Time: Comparable {

    static public func == (lfs: Time, rhs: Time) -> Bool {
        return lfs.hours == rhs.hours && lfs.minutes == rhs.minutes
    }

    static public func < (lfs: Time, rhs: Time) -> Bool {
        return lfs.totalMinutes < rhs.totalMinutes
    }
}
