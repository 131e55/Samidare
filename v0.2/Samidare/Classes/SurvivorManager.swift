//
//  SurvivorManager.swift
//  Samidare
//
//  Created by Keisuke Kawamura on 2018/09/30.
//

import UIKit

extension SamidareView {

    final internal class SurvivorManager {

        struct JudgeResult {
            let survivors: Set<IndexPath>
            let difference: (birth: Set<IndexPath>, death: Set<IndexPath>)

            static var empty: JudgeResult {
                return JudgeResult(survivors: [], difference: ([], []))
            }
        }

        var expansionRateOfSurvivorArea: CGFloat = 2 {
            didSet {
                expansionRateOfSurvivorArea = max(expansionRateOfSurvivorArea, 1)
            }
        }
        private var layoutData: EventScrollViewLayoutData!
        private(set) var survivorArea: CGRect = .zero
        private(set) var survivorIndexPaths: Set<IndexPath> = []
        private(set) var judgeResult: JudgeResult = .empty

        var didSetup: Bool {
            return layoutData != nil
        }

        func setup(layoutData: EventScrollViewLayoutData) {
            self.layoutData = layoutData
        }

        func resetSurvivorArea(of scrollView: UIScrollView) {
            let scrollViewWidth = scrollView.bounds.width
            let survivorAreaX = scrollView.contentOffset.x
                                - (scrollViewWidth * (expansionRateOfSurvivorArea - 1) / 2)
            let expandedWidth = scrollViewWidth * expansionRateOfSurvivorArea
            survivorArea = CGRect(x: survivorAreaX,
                                  y: scrollView.contentOffset.y,
                                  width: expandedWidth,
                                  height: scrollView.bounds.height)
            judge()
        }

        func resetSurvivorIndexPaths(_ indexPaths: Set<IndexPath>) {
            survivorIndexPaths = indexPaths
            judge()
        }

        private func judge() {
            guard didSetup else { return }
            let lastSurvivorIndexPaths = self.survivorIndexPaths
            var newSurvivorIndexPaths: Set<IndexPath> = []

            for indexPath in layoutData.indexPaths {
                guard let x = layoutData.xPositionOfColumn[indexPath],
                    let width = layoutData.widthOfColumn[indexPath] else { continue }
                let columnRange = x ... x + width
                let survivorRange = survivorArea.minX ... survivorArea.minX + survivorArea.width

                if survivorRange.overlaps(columnRange) {
                    newSurvivorIndexPaths.insert(indexPath)
                }
            }

            let birth = newSurvivorIndexPaths.subtracting(lastSurvivorIndexPaths)
            let death = lastSurvivorIndexPaths.subtracting(newSurvivorIndexPaths)
            judgeResult = JudgeResult(survivors: newSurvivorIndexPaths,
                                      difference: (birth, death))
        }
    }
}
