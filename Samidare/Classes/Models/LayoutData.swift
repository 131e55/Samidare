//
//  LayoutData.swift
//  Samidare
//
//  Created by Keisuke Kawamura on 2019/07/13.
//

import UIKit

internal typealias PointX = CGFloat
public typealias Height = CGFloat
public typealias Second = Int
public typealias Minute = Int

protocol LayoutDataProtocol {
    var timeRange: ClosedRange<Date> { get }
    var layoutUnit: LayoutUnit { get }
    
    var ceilingNumberOfMinuteUnits: Int { get }
    var totalHeightForTimeRange: CGFloat { get }
    func roundedDistanceOfTimeRangeStart(to date: Date) -> CGFloat
    func roundedHeight(from seconds: Second) -> CGFloat
    func roundedMinutes(from height: Height) -> Int
}

extension LayoutDataProtocol {
    /// Number of minute units computed by timeRange and layoutUnit.
    ///
    /// ex.) 60 min, 10 unit = 6 units
    /// ex.) 61 min, 10 unit = 7 units
    var ceilingNumberOfMinuteUnits: Int {
        let minutes = timeRange.ceilingDurationInMinutes
        let unit = layoutUnit.minuteUnit
        return minutes / unit + (minutes % unit == 0 ? 0 : 1)
    }
    
    /// Total height for timRange. It'll be computed by ceilingNumberOfMinuteUnits and layoutUnit.
    var totalHeightForTimeRange: CGFloat {
        return CGFloat(ceilingNumberOfMinuteUnits) * layoutUnit.heightUnit
    }
    
    /// Distance of timeRange.lowerBound to date. It'll be rounded by layoutUnit.
    func roundedDistanceOfTimeRangeStart(to date: Date) -> CGFloat {
        let isPast = date < timeRange.lowerBound
        let range = isPast ? date ... timeRange.lowerBound : timeRange.lowerBound ... date
        let minutes = range.roundedDurationInMinutes
        let numberOfUnits = Int(round(Float(minutes) / Float(layoutUnit.minuteUnit)))
        let distance = (isPast ? -1 : 1) * CGFloat(numberOfUnits) * layoutUnit.heightUnit
        return distance
    }
    
    /// Height computed by seconds and layoutUnit.
    func roundedHeight(from seconds: Second) -> CGFloat {
        let minutes = roundedMinutes(from: seconds)
        let numberOfUnits = Int(round(Float(minutes) / Float(layoutUnit.minuteUnit)))
        let height = CGFloat(numberOfUnits) * layoutUnit.heightUnit
        return height
    }
    
    private func roundedMinutes(from seconds: Second) -> Int {
        let floorMinutes = seconds / 60
        let roundedMinutes = floorMinutes + (seconds % 60 >= 30 ? 1 : 0)
        return roundedMinutes
    }
    
    /// Minutes computed by height and layoutUnit.
    func roundedMinutes(from height: Height) -> Int {
        let numberOfUnits = Int(round(height / layoutUnit.heightUnit))
        return layoutUnit.minuteUnit * numberOfUnits
    }
}

public struct LayoutUnit {
    /// Minute unit for displaying EventCell.
    public let minuteUnit: Minute
    /// Height unit for displaying EventCell.
    public let heightUnit: CGFloat
    /// Initial minutes in creating EventCell.
    public let initialMinutesInCreating: Minute
}

internal struct EventScrollViewLayoutData: LayoutDataProtocol {
    let timeRange: ClosedRange<Date>
    let layoutUnit: LayoutUnit
    let indexPaths: [IndexPath]
    let xPositionOfColumn: [IndexPath: CGFloat]
    let widthOfColumn: [IndexPath: CGFloat]
    let totalWidthOfColumns: CGFloat
    let columnSpacing: CGFloat
    let totalSpacingOfColumns: CGFloat
    
    /// IndexPath computed by contentOffset.x and layoutUnit.
    func indexPath(from x: PointX) -> IndexPath {
        var result: IndexPath = indexPaths.last!
        for indexPath in indexPaths {
            let columnX = xPositionOfColumn[indexPath]!
            if x >= columnX {
                result = indexPath
            } else {
                return result
            }
        }
        return result
    }
}

internal struct TimeScrollViewLayoutData: LayoutDataProtocol  {
    let timeRange: ClosedRange<Date>
    let layoutUnit: LayoutUnit
    let widthOfColumn: CGFloat
}
