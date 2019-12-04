//
//  AnimatedStringLayer.swift
//  TextAnimation
//
//  Created by Sergey V. Krupov on 04.12.2019.
//  Copyright © 2019 Sergey V. Krupov. All rights reserved.
//

import UIKit

final class AnimatedStringLayer: CALayer {

    var text: String? {
        didSet {
            rebuildSublayers()
        }
    }

    var font: CTFont = CTFontCreateWithName("Helvetica-Bold" as CFString, 30, nil) {
        didSet {
            rebuildSublayers()
        }
    }

    func animate() {
        for (offset, layer) in glyphs.reversed().enumerated() {
            animateLayer(layer: layer, index: offset)
        }
    }

    // MARK: - Private
    private var glyphs: [CALayer] = []

    private func rebuildSublayers() {
        glyphs.forEach {
            $0.removeFromSuperlayer()
        }
        glyphs = []

        guard let text = text else {
            return
        }

        let string = NSAttributedString(string: text, attributes: [.font: font])
        let line = CTLineCreateWithAttributedString(string)
        let runs = CTLineGetGlyphRuns(line) as! [CTRun]

        var layers: [GlyphLayer] = []
        for run in runs {
            let glyphsCount = CTRunGetGlyphCount(run)
            let attributes = CTRunGetAttributes(run) as! [String: Any]
            let font = attributes[kCTFontAttributeName as String] as! CTFont

            for index in 0 ..< glyphsCount {
                let range = CFRangeMake(index, 1)
                var glyph = CGGlyph()
                withUnsafeMutablePointer(to: &glyph) { pointer in
                    CTRunGetGlyphs(run, range, pointer)
                }

                var position = CGPoint()
                withUnsafeMutablePointer(to: &position) { pointer in
                    CTRunGetPositions(run, range, pointer)
                }

                var rect = CGRect.zero
                _ = withUnsafeMutablePointer(to: &rect) { ptrRect in
                    withUnsafePointer(to: &glyph) { ptrGlyph in
                        CTFontGetBoundingRectsForGlyphs(font, .horizontal, ptrGlyph, ptrRect, 1)
                    }
                }

                let layer = GlyphLayer(glyph: glyph, font: font, offset: CGPoint(x: ceil(-rect.origin.x), y: ceil(-rect.origin.y)))
                layer.frame = CGRect(x: rect.minX + position.x, y: rect.minY + position.y, width: ceil(rect.width), height: ceil(rect.height))
                layers.append(layer)
            }
        }

        var boundingRect = layers.first?.frame ?? .zero
        boundingRect = layers.reduce(boundingRect) { $0.union($1.frame) }
        for layer in layers {
            let frame = layer.frame
            layer.frame = CGRect(x: frame.minX, y: boundingRect.maxY - frame.height, width: frame.width, height: frame.height)
            addSublayer(layer)
            glyphs.append(layer)
        }
        bounds.size = boundingRect.size
    }

    private func animateLayer(layer: CALayer, index: Int) {
        let param1: CGFloat = 30
        let duration1: CFTimeInterval = 3

        layer.removeAllAnimations()

        var animations: [CAAnimation] = []

        let startTimeOffset = 0.05 * CFTimeInterval(index)

        if index > 0 {
            let dummyAnimation = CABasicAnimation(keyPath: "transform")
            dummyAnimation.fromValue = CATransform3DMakeScale(0, 0, 1)
            dummyAnimation.toValue = CATransform3DMakeScale(0, 0, 1)
            dummyAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
            dummyAnimation.duration = startTimeOffset
            animations.append(dummyAnimation)
        }

        let fromScale = CATransform3DMakeScale(0, 0, 1)
        let toScale = CATransform3DMakeRotation(.pi / 2, 0, 0, 1) 

        let animateScale = CABasicAnimation(keyPath: "transform")
        animateScale.fromValue = fromScale
        animateScale.toValue = toScale
        animateScale.timingFunction = CAMediaTimingFunction(name: .easeOut)
        animateScale.duration = duration1
        animateScale.beginTime = startTimeOffset
        animations.append(animateScale)

        let radius: CGFloat = CGFloat.random(in: 50 ... 200)
        let position = CGPoint(x: layer.position.x, y: layer.position.y - param1)
        let path = CGMutablePath()
        path.addRelativeArc(center: CGPoint(x: position.x - radius, y: position.y), radius: radius, startAngle: .pi, delta: -CGFloat.pi)

        let animatePosition = CAKeyframeAnimation(keyPath: "position")
        animatePosition.path = path
        animatePosition.timingFunction = CAMediaTimingFunction(name: .easeOut)
        animatePosition.duration = duration1
        animatePosition.rotationMode = .rotateAuto
        animatePosition.beginTime = startTimeOffset
        animations.append(animatePosition)

        let duration2: CFTimeInterval = 2
        let animateBounce = BouncePositionAnimation(fromValue: position, toValue: CGPoint(x: position.x, y: position.y + param1))
        animateBounce.duration = duration2
        animateBounce.beginTime = duration1 + startTimeOffset
        animations.append(animateBounce)

        let group = CAAnimationGroup()
        group.animations = animations
        group.duration = duration1 + duration2 + startTimeOffset
        // group.timeOffset = -0.05 * CFTimeInterval(index)
        //group.beginTime = 0.05 * CFTimeInterval(index)
        //group.delegate = self

        layer.add(group, forKey: "animate")
    }
}

extension AnimatedStringLayer: CAAnimationDelegate {

    func animationDidStart(_ anim: CAAnimation) {
//        if anim is CAAnimationGroup {
//            for layer in glyphs {
//                layer.transform = CATransform3DMakeScale(0, 0, 1)
//            }
//        }
    }

    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
    }
}
