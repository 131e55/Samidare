//
//  EventScrollView+Creator.swift
//  Samidare
//
//  Created by Keisuke Kawamura on 2019/07/16.
//

import UIKit

internal extension EventScrollView {
    final class Creator {

        private weak var eventScrollView: EventScrollView?
        
        /// First touch location in referencing EventScrollView.
        /// It's reset each time any gesture recognized.
        private var firstTouchLocation: CGPoint!
        /// Last touch location in referencing EventScrollView.
        private var lastTouchLocation: CGPoint!
        
        /// Setup Creator
        ///
        /// - Parameters:
        ///   - eventScrollView: EventScrollView to apply Creator function.
        internal func setup(eventScrollView: EventScrollView) {
            self.eventScrollView = eventScrollView
            let longPressGesture = UILongPressGestureRecognizer(target: self,
                                                                action: #selector(eventScrollViewWasLongPressed))
            eventScrollView.addGestureRecognizer(longPressGesture)
        }
        
        @objc private func eventScrollViewWasLongPressed(_ sender: UILongPressGestureRecognizer) {
            dprint("eventScrollViewWasLongPressed")
        }
    }
}

// didCreateEvent -> IndexPath, ClosedRange<Date>
//
