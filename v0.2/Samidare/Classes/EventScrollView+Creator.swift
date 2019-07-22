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

        /// First touch location in referencing EventScrollView.
        /// It's reset each time any gesture recognized.
        private var firstTouchLocation: CGPoint!
        /// Last touch location in referencing EventScrollView.
        private var lastTouchLocation: CGPoint!
        
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
            dprint("eventScrollViewWasLongPressed")
        }
        
        @objc private func eventScrollViewWasLongPressed(_ sender: UILongPressGestureRecognizer) {
            switch sender.state {
            case .began:
                beginCreating(atPointInEventScrollView: sender.location(in: eventScrollView))
                let location = sender.location(in: eventScrollView)
                let indexPath = eventScrollView.layoutData.indexPath(from: location.x)
//                let eventCell = willCreateEventHandler()
//                let eventCell = EventCell(frame: .zero)
                dprint(indexPath)
                break
            default:
                break
            }
            dprint("eventScrollViewWasLongPressed")
        }
        
        private func beginCreating(atPointInEventScrollView point: CGPoint) {
            guard let layoutData = eventScrollView.layoutData else { return }
            let indexPath = layoutData.indexPath(from: point.x)
            let minutes = layoutData.roundedMinutes(from: point.y)
            dprint(layoutData.timeRange.lowerBound)
            let startDate = layoutData.timeRange.lowerBound.addingTimeInterval(TimeInterval(minutes * 60))
            let endDate = startDate.addingTimeInterval(TimeInterval(layoutData.layoutUnit.minuteUnit * 60))
            let event = Event(time: startDate ... endDate)
            dprint(startDate, endDate)
            let creatingCell = willCreateEventHandler(event, indexPath)
            
        }
    }
}

// willCreateEventHandler(IndexPath) -> EventCell
//
