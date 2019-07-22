//
//  LayoutData.swift
//  Samidare
//
//  Created by Keisuke Kawamura on 2019/07/13.
//

import Foundation

public struct LayoutUnit {
    /// Minute unit for displaying EventCell.
    public let minuteUnit: Int
    /// Height unit for displaying EventCell.
    public let heightUnit: CGFloat
}

internal typealias PointX = CGFloat
internal typealias Height = CGFloat
internal typealias Second = Int

internal struct LayoutData {
    let timeRange: ClosedRange<Date>
    let layoutUnit: LayoutUnit
    let indexPaths: [IndexPath]
    let xPositionOfColumn: [IndexPath: CGFloat]
    let widthOfColumn: [IndexPath: CGFloat]
    let totalWidthOfColumns: CGFloat
    let widthOfTimeColumn: CGFloat
    let columnSpacing: CGFloat

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

    /// Minutes computed by height and layoutUnit.
    func roundedMinutes(from height: Height) -> Int {
        let numberOfUnits = Int(round(height / layoutUnit.heightUnit))
        return layoutUnit.minuteUnit * numberOfUnits
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
