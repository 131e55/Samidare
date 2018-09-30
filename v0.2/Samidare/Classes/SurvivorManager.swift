//
//  SurvivorManager.swift
//  Samidare
//
//  Created by Keisuke Kawamura on 2018/09/30.
//

import Foundation

extension SamidareView {
final internal class SurvivorManager {

    var expansionRateOfSurvivorArea: CGFloat = 2 {
        didSet {
            expansionRateOfSurvivorArea = max(expansionRateOfSurvivorArea, 1)
        }
    }
    var survivorArea: CGRect = .zero
    private(set) var survivorIndexPath: [IndexPath] = []

    private(set) var layoutData: LayoutDataStore.LayoutData!

    var didSetup: Bool {
        return layoutData != nil
    }

    func setup(layoutData: LayoutDataStore.LayoutData) {
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
        print("survivorArea", survivorArea)
    }

    func judge() {
        guard didSetup else { print("SurvivorManager not setup yet"); return }

        var result: (survive: [IndexPath], bear: [IndexPath], kill: [IndexPath]) = ([], [], [])

        for indexPath in layoutData.indexPaths {
            let x = layoutData.xPositionOfEventColumn[indexPath]!
            if survivorArea.contains(CGPoint(x: x, y: survivorArea.minY)) {
                if survivorIndexPath.contains(indexPath) == false {

                }
            }
        }
    }
}
}
