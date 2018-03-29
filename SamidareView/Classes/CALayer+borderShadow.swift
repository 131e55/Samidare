//
//  CALayer+borderShadow.swift
//
//  Created by Keisuke Kawamura on 2018/03/29.
//

import UIKit

extension CALayer {

    func drawBorderShadow(borderWidth: CGFloat, shadowRadius: CGFloat? = nil, shadowOpacity: Float? = nil, shadowColor: CGColor? = nil) {

        self.shadowRadius = shadowRadius ?? self.shadowRadius
        self.shadowOpacity = shadowOpacity ?? self.shadowOpacity
        self.shadowColor = shadowColor ?? self.shadowColor

        let radius = cornerRadius
        let width = frame.width
        let height = frame.height
        let points: [CGPoint] = [
            // Outside
            CGPoint(x: -borderWidth + radius, y: -borderWidth),
            CGPoint(x: width + borderWidth - radius, y: -borderWidth),
            CGPoint(x: width + borderWidth - radius, y: -borderWidth + radius),          // arc center
            // Inside
            CGPoint(x: width, y: radius),
            CGPoint(x: width - radius, y: radius),  // arc center
            CGPoint(x: radius, y: 0),
            CGPoint(x: radius, y: radius),          // arc center
            CGPoint(x: 0, y: height - radius),
            CGPoint(x: radius, y: height - radius), // arc center
            CGPoint(x: width - radius, y: height),
            CGPoint(x: width - radius, y: height - radius), // arc center
            CGPoint(x: width, y: radius),
            // Outside
            CGPoint(x: width + borderWidth, y: -borderWidth + radius),
            CGPoint(x: width + borderWidth, y: height + borderWidth - radius),
            CGPoint(x: width + borderWidth - radius, y: height + borderWidth - radius), // arc center
            CGPoint(x: -borderWidth + radius, y: height + borderWidth),
            CGPoint(x: -borderWidth + radius, y: height + borderWidth - radius),        // arc center
            CGPoint(x: -borderWidth, y: -borderWidth + radius),
            CGPoint(x: -borderWidth + radius, y: -borderWidth + radius)                 // arc center
        ]

        let path = CGMutablePath()
        // Outside
        path.move(to: points[0])
        path.addLine(to: points[1])
        path.addArc(center: points[2], radius: radius, startAngle: -.pi / 2, endAngle: 0, clockwise: false)
        // Inside
        path.addLine(to: points[3])
        path.addArc(center: points[4], radius: radius, startAngle: 0, endAngle: -.pi / 2, clockwise: true)
        path.addLine(to: points[5])
        path.addArc(center: points[6], radius: radius, startAngle: -.pi / 2, endAngle: .pi, clockwise: true)
        path.addLine(to: points[7])
        path.addArc(center: points[8], radius: radius, startAngle: .pi, endAngle: .pi / 2, clockwise: true)
        path.addLine(to: points[9])
        path.addArc(center: points[10], radius: radius, startAngle: .pi / 2, endAngle: 0, clockwise: true)
        path.addLine(to: points[11])
        // Outside
        path.addLine(to: points[12])
        path.addLine(to: points[13])
        path.addArc(center: points[14], radius: radius, startAngle: 0, endAngle: .pi / 2, clockwise: false)
        path.addLine(to: points[15])
        path.addArc(center: points[16], radius: radius, startAngle: .pi / 2, endAngle: .pi, clockwise: false)
        path.addLine(to: points[17])
        path.addArc(center: points[18], radius: radius, startAngle: .pi, endAngle: -.pi / 2, clockwise: false)

        shadowOffset = .zero
        masksToBounds = false
        rasterizationScale = UIScreen.main.scale
        shouldRasterize = true
        shadowPath = path
    }
}
