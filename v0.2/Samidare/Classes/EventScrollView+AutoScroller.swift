//
//  EventScrollView+AutoScroller.swift
//  Samidare
//
//  Created by Keisuke Kawamura on 2018/11/03.
//

import UIKit

extension EventScrollView {

    internal class AutoScroller {

        private struct ScrollingStrength {
            var top: CGFloat
            var left: CGFloat
            var bottom: CGFloat
            var right: CGFloat
        }

        private weak var eventScrollView: EventScrollView?

        /// Threshold for determine whether should scroll.
        private let threshold: CGFloat = 0.1
        /// Minimum speed of automatic scrolling [point per frame].
        private let minSpeed: CGFloat = 50
        /// Maximum speed of automatic scrolling [point per frame].
        private let maxSpeed: CGFloat = 500

        private var location: CGPoint!
        private var displayLink: CADisplayLink?
        private var displayLinkLastTimeStamp: CFTimeInterval!

        internal func setup(eventScrollView: EventScrollView) {
            self.eventScrollView = eventScrollView
        }

        /// - Parameter location: location in referencing EventScrollView.
        private func shouldAutoScroll(location: CGPoint) -> (should: Bool, strength: ScrollingStrength) {
            var strength = ScrollingStrength(top: 0, left: 0, bottom: 0, right: 0)
            guard let eventScrollView = eventScrollView else { return (false, strength) }
            let width = eventScrollView.bounds.width
            let height = eventScrollView.bounds.height
            let xRate = max(location.x / width, 0)
            let yRate = max(location.y / height, 0)

            if yRate <= threshold {
                strength.top = min(1 - yRate / threshold, 1)
            }
            if xRate <= threshold {
                strength.left = min(1 - xRate / threshold, 1)
            }
            if yRate >= 1 - threshold {
                strength.bottom = min((yRate - (1 - threshold)) * 10, 1)
            }
            if xRate >= 1 - threshold {
                strength.right = min((xRate / (1 - threshold)) * 10, 1)
            }
            let should = strength.top + strength.left + strength.bottom + strength.right > 0
            return (should, strength)
        }

        /// - Parameter location: location in referencing EventScrollView.
        internal func autoScrollIfNeeded(location: CGPoint) {
            self.location = location
            if shouldAutoScroll(location: location).should {
                if displayLink == nil {
                    displayLink = CADisplayLink(target: self, selector: #selector(handleDisplayLink))
                    displayLink!.add(to: .main, forMode: RunLoop.Mode.default)
                }
            } else {
                invalidateDisplayLink()
            }
        }

        private func invalidateDisplayLink() {
            displayLink?.invalidate()
            displayLink = nil
            displayLinkLastTimeStamp = nil
        }

        @objc private func handleDisplayLink(_ displayLink: CADisplayLink) {
            guard let scrollView = eventScrollView else { return }
            let shouldScroll = shouldAutoScroll(location: location)
            guard shouldScroll.should else { invalidateDisplayLink(); return }

            if let lastTime = displayLinkLastTimeStamp {

                let deltaTime = displayLink.timestamp - lastTime
                let minContentOffsetY = -scrollView.contentInset.top
                //            let minContentOffsetX = -scrollView.contentInset.left
                let maxContentOffsetY = scrollView.contentSize.height - scrollView.bounds.height + scrollView.contentInset.bottom
                //            let maxContentOffsetX = scrollView.contentSize.width - scrollView.bounds.width + scrollView.contentInset.right

                if shouldScroll.strength.top > 0 {
                    let strength = shouldScroll.strength.top
                    let velocity = -1 * ((maxSpeed - minSpeed) * strength + minSpeed) * CGFloat(deltaTime)
                    scrollView.contentOffset.y += velocity
                    scrollView.contentOffset.y = max(scrollView.contentOffset.y, minContentOffsetY)
                } else if shouldScroll.strength.bottom > 0 {
                    let strength = shouldScroll.strength.bottom
                    let velocity = ((maxSpeed - minSpeed) * strength + minSpeed) * CGFloat(deltaTime)
                    scrollView.contentOffset.y += velocity
                    scrollView.contentOffset.y = min(scrollView.contentOffset.y, maxContentOffsetY)
                }
                // Not support yet
                //            if shouldScroll.strength.left > 0 {
                //                let strength = shouldScroll.strength.left
                //                let velocity = -1 * ((maxSpeed - minSpeed) * strength + minSpeed) * CGFloat(deltaTime)
                //                scrollView.contentOffset.x += velocity
                //                scrollView.contentOffset.x = max(scrollView.contentOffset.x, minContentOffsetX)
                //            } else if shouldScroll.strength.right > 0 {
                //                let strength = shouldScroll.strength.right
                //                let velocity = ((maxSpeed - minSpeed) * strength + minSpeed) * CGFloat(deltaTime)
                //                scrollView.contentOffset.x += velocity
                //                scrollView.contentOffset.x = min(scrollView.contentOffset.x, maxContentOffsetX)
                //            }

//                updateEditingViewFrame(type: lastEditingType!)
            }

            displayLinkLastTimeStamp = displayLink.timestamp
        }
    }
}

