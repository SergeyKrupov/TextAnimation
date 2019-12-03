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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let text = "Foo-Bar😃dd"
        let font = CTFontCreateWithName("Helvetica-Bold" as CFString, 50, nil)

        let layers = createGlyphLayers(text: text, font: font)

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

    }
}

