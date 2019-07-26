//
//  EventScrollView+Creator.swift
//  Samidare
//
//  Created by Keisuke Kawamura on 2019/07/16.
//

import UIKit

public typealias CreatorWillCreateEventHandler = (_ event: Event, _ indexPath: IndexPath) -> EventCell

internal extension EventScrollView {
    
    final class Creator {
        
        private weak var eventScrollView: EventScrollView!

        internal var willCreateEventHandler: CreatorWillCreateEventHandler!
        
        private weak var cellInCreating: EventCell?
        private let editor: Editor = Editor()
        
        /// Setup Creator
        ///
        /// - Parameters:
        ///   - eventScrollView: EventScrollView to apply Creator function.
        internal func setup(eventScrollView: EventScrollView,
                            willCreateEventHandler: @escaping CreatorWillCreateEventHandler) {
            self.eventScrollView = eventScrollView
            self.willCreateEventHandler = willCreateEventHandler
            let longPressGesture = UILongPressGestureRecognizer(target: self,
                                                                action: #selector(eventScrollViewWasLongPressed))
            eventScrollView.addGestureRecognizer(longPressGesture)
            editor.setup(eventScrollView: eventScrollView, displaysOriginalCell: false)
        }
        
        @objc private func eventScrollViewWasLongPressed(_ sender: UILongPressGestureRecognizer) {
            if sender.state == .began {
                beginCreating(atPointInEventScrollView: sender.location(in: eventScrollView))
            }
            editor.simulateBottomKnobPanning(sender)
        }
        
        private func beginCreating(atPointInEventScrollView point: CGPoint) {
            guard let layoutData = eventScrollView.layoutData else { fatalError() }
            let indexPath = layoutData.indexPath(from: point.x)
            guard let x = layoutData.xPositionOfColumn[indexPath],
                let width = layoutData.widthOfColumn[indexPath] else { fatalError() }
            let minutes = layoutData.roundedMinutes(from: point.y)
            let startDate = layoutData.timeRange.lowerBound.addingTimeInterval(TimeInterval(minutes * 60))
            let endDate = startDate.addingTimeInterval(TimeInterval(layoutData.layoutUnit.initialMinutesInCreating * 60))
            let event = Event(time: startDate ... endDate)
            let cell = willCreateEventHandler(event, indexPath)
            let y = layoutData.roundedDistanceOfTimeRangeStart(to: cell.event.start)
            let height = layoutData.roundedHeight(from: cell.event.durationInSeconds)
            cell.frame = CGRect(x: x, y: y, width: width, height: height)
            eventScrollView.addSubview(cell)
            self.cellInCreating = cell
            
            editor.beginEditing(for: cell)
        }
    }
}
