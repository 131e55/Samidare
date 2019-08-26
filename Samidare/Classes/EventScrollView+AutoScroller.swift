//
//  EventScrollView+AutoScroller.swift
//  Samidare
//
//  Created by Keisuke Kawamura on 2018/11/03.
//

import UIKit

internal extension EventScrollView {

    final class AutoScroller: NSObject, UIGestureRecognizerDelegate {

        private struct ScrollingStrength {
            var top: CGFloat
            var left: CGFloat
            var bottom: CGFloat
            var right: CGFloat
            var isAllZero: Bool {
                return top + left + bottom + right == 0
            }
        }

        private weak var eventScrollView: EventScrollView?

        /// Threshold for determine whether should scroll.
        private let threshold: CGFloat = 0.15
        /// Minimum speed of automatic scrolling [point per frame].
        private let minSpeed: CGFloat = 10
        /// Maximum speed of automatic scrolling [point per frame].
        private let maxSpeed: CGFloat = 500

        /// Touch location in referencing EventScrollView's bounds.
        private var touchLocation: CGPoint = .zero
        private var displayLink: CADisplayLink?
        private var displayLinkLastTimeStamp: CFTimeInterval!

        internal var isEnabled: Bool = false {
            didSet {
                if !isEnabled {
                    invalidateDisplayLink()
                }
            }
        }

        internal func setup(eventScrollView: EventScrollView) {
            self.eventScrollView = eventScrollView

            let recognizer = UIPanGestureRecognizer(target: self, action: #selector(didPan))
            recognizer.delegate = self
            eventScrollView.addGestureRecognizer(recognizer)
        }

        @objc private func didPan(_ sender: UIGestureRecognizer) {
            guard let scrollView = eventScrollView else { return }

            switch sender.state {
            case .began, .changed:
                let locationInContentSize = sender.location(in: scrollView)
                touchLocation = CGPoint(x: locationInContentSize.x - scrollView.contentOffset.x,
                                        y: locationInContentSize.y - scrollView.contentOffset.y)
                autoScrollIfNeeded()

            default:
                isEnabled = false
            }
        }

        /// - Parameter location: location in referencing EventScrollView's bounds
        private func scrollingStrength(location: CGPoint) -> ScrollingStrength {
            var strength = ScrollingStrength(top: 0, left: 0, bottom: 0, right: 0)
            guard let eventScrollView = eventScrollView else { return strength }
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
                strength.right = min((xRate - (1 - threshold)) * 10, 1)
            }
            return strength
        }

        private func autoScrollIfNeeded() {
            if !scrollingStrength(location: touchLocation).isAllZero {
                if displayLink == nil {
                    displayLink = CADisplayLink(target: self, selector: #selector(handleDisplayLink))
                    displayLink!.add(to: .main, forMode: RunLoop.Mode.default)
                }
            }
            else {
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

            let scrollingStrength = self.scrollingStrength(location: touchLocation)
            if scrollingStrength.isAllZero {
                invalidateDisplayLink()
            }
            else {
                if let lastTime = displayLinkLastTimeStamp {
                    let deltaTime = displayLink.timestamp - lastTime
                    let minContentOffsetY = -scrollView.contentInset.top
                    let minContentOffsetX = -scrollView.contentInset.left
                    let maxContentOffsetY = scrollView.contentSize.height
                                            - scrollView.bounds.height
                                            + scrollView.contentInset.bottom
                    let maxContentOffsetX = scrollView.contentSize.width
                                            - scrollView.bounds.width
                                            + scrollView.contentInset.right

                    var newContentOffset = scrollView.contentOffset

                    // Top or Bottom
                    if scrollingStrength.top > 0 {
                        let velocity = -1 * ((maxSpeed - minSpeed) * scrollingStrength.top + minSpeed)
                                       * CGFloat(deltaTime)
                        newContentOffset.y += velocity
                        newContentOffset.y = max(newContentOffset.y, minContentOffsetY)
                    }
                    else if scrollingStrength.bottom > 0 {
                        let velocity = ((maxSpeed - minSpeed) * scrollingStrength.bottom + minSpeed)
                                       * CGFloat(deltaTime)
                        newContentOffset.y += velocity
                        newContentOffset.y = min(newContentOffset.y, maxContentOffsetY)
                    }
                    // Left or Right
                    if scrollingStrength.left > 0 {
                        let velocity = -1 * ((maxSpeed - minSpeed) * scrollingStrength.left + minSpeed)
                                       * CGFloat(deltaTime)
                        newContentOffset.x += velocity
                        newContentOffset.x = max(newContentOffset.x, minContentOffsetX)
                    }
                    else if scrollingStrength.right > 0 {
                        let velocity = ((maxSpeed - minSpeed) * scrollingStrength.right + minSpeed)
                                       * CGFloat(deltaTime)
                        newContentOffset.x += velocity
                        newContentOffset.x = min(newContentOffset.x, maxContentOffsetX)
                    }

                    scrollView.contentOffset = newContentOffset

    //                updateEditingViewFrame(type: lastEditingType!)
                }

                displayLinkLastTimeStamp = displayLink.timestamp
            }
        }

        // MARK: - UIGestureRecognizerDelegate

        internal func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            return isEnabled
        }

        internal func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            return true
        }
    }
}
