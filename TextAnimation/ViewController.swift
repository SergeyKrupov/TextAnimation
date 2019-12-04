//
//  ViewController.swift
//  TextAnimation
//
//  Created by Sergey V. Krupov on 03.12.2019.
//  Copyright © 2019 Sergey V. Krupov. All rights reserved.
//

import UIKit
import CoreText

final class GlyphLayer: CALayer {

    internal init(glyph: CGGlyph, font: CTFont, offset: CGPoint) {
        self.glyph = glyph
        self.font = font
        self.offset = offset
        super.init()

        masksToBounds = false
        setNeedsDisplay()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let glyph: CGGlyph
    let font: CTFont
    let offset: CGPoint

    override func draw(in ctx: CGContext) {
        ctx.translateBy(x: 0, y: bounds.height)
        ctx.scaleBy(x: 1.0, y: -1.0)
        var mutableGlyph = glyph
        var position = offset
        withUnsafePointer(to: &mutableGlyph) { ptrGlyph in
            withUnsafePointer(to: &position) { ptrPosition in
                CTFontDrawGlyphs(font, ptrGlyph, ptrPosition, 1, ctx)
            }
        }
    }
}

func createGlyphLayers(text: String, font: CTFont) -> [GlyphLayer] {
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
            layer.frame = CGRect(x: rect.minX + position.x, y: rect.minY + position.y + 100, width: ceil(rect.width), height: ceil(rect.height))
            layers.append(layer)
        }
    }

    return layers
}


class ViewController: UIViewController {

    @IBAction func start(_ sender: Any) {
        let layers = view.layer.sublayers?.compactMap { $0 as? GlyphLayer } ?? []
        for (offset, layer) in layers.enumerated() {
            animate1(layer: layer, index: offset)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let text = "Foo-Bar😃dd"
        let font = CTFontCreateWithName("Helvetica-Bold" as CFString, 50, nil)

        let layers = createGlyphLayers(text: text, font: font)
//        let layers: [CALayer] = glyphLayers.map {
//            let layer = CALayer()
//            layer.frame = $0.frame
//            layer.backgroundColor = UIColor.red.cgColor
//            return layer
//        }

        var rect = layers.first?.frame ?? .zero
        for layer in layers {
            rect = rect.union(layer.frame)
        }

        let position = CGPoint(x: (view.bounds.width - rect.width) / 2, y: (view.bounds.height - rect.height) / 2)

        for layer in layers {
            let frame = layer.frame
            layer.frame = CGRect(x: position.x + frame.minX, y: position.y + rect.height - frame.height, width: frame.width, height: frame.height)
            view.layer.addSublayer(layer)
        }

//        for layer in layers {
//            animate1(layer: layer)
//        }
    }

    private func animate1(layer: CALayer, index: Int) {

        let duration1: CFTimeInterval = 3

        let radius: CGFloat = CGFloat.random(in: 50 ... 200)
        let position = layer.position
        let path = CGMutablePath()
        path.addRelativeArc(center: CGPoint(x: position.x - radius, y: position.y), radius: radius, startAngle: .pi, delta: -CGFloat.pi)

        let animatePosition = CAKeyframeAnimation(keyPath: "position")
        animatePosition.path = path
        animatePosition.timingFunction = CAMediaTimingFunction(name: .easeOut)
        animatePosition.duration = duration1
        animatePosition.rotationMode = .rotateAuto

        let fromScale = CATransform3DMakeScale(0, 0, 1)
        let toScale = CATransform3DMakeRotation(.pi / 2, 0, 0, 1) //CATransform3DIdentity

        let animateScale = CABasicAnimation(keyPath: "transform")
        animateScale.fromValue = fromScale
        animateScale.toValue = toScale
        animateScale.timingFunction = CAMediaTimingFunction(name: .easeOut)
        animateScale.duration = duration1

        let duration2: CFTimeInterval = 2
        let animateSpring = BouncePositionAnimation(fromValue: position, toValue: CGPoint(x: position.x, y: position.y + 50))
        animateSpring.duration = duration2
        animateSpring.beginTime   = duration1 + CFTimeInterval(index) * 0.1

        let group = CAAnimationGroup()
        group.animations = [animateScale, animatePosition, animateSpring]
        group.duration = duration1 + duration2 + 5

        layer.add(group, forKey: "animate1")
    }
}

final class BouncePositionAnimation: CAKeyframeAnimation {

    init(fromValue: CGPoint, toValue: CGPoint) {
        self.fromValue = fromValue
        self.toValue = toValue
        super.init()
        keyPath = "position"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let fromValue: CGPoint
    private let toValue: CGPoint

    override var values: [Any]? {
        get {
            let duration = self.duration
            var values: [Any] = []

            let count = Int(duration * 60)
            for index in 0 ... count {
                values.append(evaluate(moment: CFTimeInterval(index) / 60.0, duration: duration))
            }

            return values
        }
        set {
        }
    }

    func evaluate(moment: CFTimeInterval, duration: CFTimeInterval) -> CGPoint {
        let fraction = easeOutBounce(moment / duration)
        return CGPoint(
            x: Double(fromValue.x) + Double(toValue.x - fromValue.x) * fraction,
            y: Double(fromValue.y) + Double(toValue.y - fromValue.y) * fraction
        )
    }

    func easeOutBounce(_ t: Double) -> Double {
        if (t < 4.0 / 11.0) {
            return pow(11.0 / 4.0, 2) * pow(t, 2);
        }

        if (t < 8.0 / 11.0) {
            return 3.0 / 4.0 + pow(11.0 / 4.0, 2) * pow(t - 6.0 / 11.0, 2);
        }

        if (t < 10.0 / 11.0) {
            return 15.0 / 16.0 + pow(11.0 / 4.0, 2) * pow(t - 9.0 / 11.0, 2);
        }

        return 63.0 / 64.0 + pow(11.0 / 4.0, 2) * pow(t - 21.0 / 22.0, 2);
    }
}
