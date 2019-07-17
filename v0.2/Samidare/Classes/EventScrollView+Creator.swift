//
//  EventScrollView+Creator.swift
//  Samidare
//
//  Created by Keisuke Kawamura on 2019/07/16.
//

import UIKit

internal extension EventScrollView {
    
    final class Creator {
        
        private weak var eventScrollView: EventScrollView!

        internal var willCreateEventHandler: (() -> EventCell)!

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
                            willCreateEventHandler: @escaping () -> EventCell) {
            self.eventScrollView = eventScrollView
            self.willCreateEventHandler = willCreateEventHandler
            let longPressGesture = UILongPressGestureRecognizer(target: self,
                                                                action: #selector(eventScrollViewWasLongPressed))
            eventScrollView.addGestureRecognizer(longPressGesture)
        }
        
        @objc private func eventScrollViewWasLongPressed(_ sender: UILongPressGestureRecognizer) {
            switch sender.state {
            case .began:
                let eventCell = willCreateEventHandler()
            default:
                break
            }
            dprint("eventScrollViewWasLongPressed")
        }
    }
}

// willCreateEventHandler(IndexPath) -> EventCell
//
