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

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        let text = "Foo-Bar😃dd"
        let font = CTFontCreateWithName("Helvetica-Bold" as CFString, 50, nil)
        let string = NSAttributedString(string: text, attributes: [.font: font])

        let line = CTLineCreateWithAttributedString(string)
        let runs = CTLineGetGlyphRuns(line) as! [CTRun]

        var textIndex = text.startIndex

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

                //let letter = CTFontCreatePathForGlyph(ctFont, glyph, nil)
                var rect = CGRect.zero
                withUnsafeMutablePointer(to: &rect) { ptrRect in
                    withUnsafePointer(to: &glyph) { ptrGlyph in
                        CTFontGetBoundingRectsForGlyphs(font, .horizontal, ptrGlyph, ptrRect, 1)
                    }
                }

//                let shapeLayer = CAShapeLayer()r
//                shapeLayer.path = CTFontCreatePathForGlyph(font, glyph, nil)
//                shapeLayer.frame = rect.offsetBy(dx: position.x, dy: position.y + 500)
//                view.layer.addSublayer(shapeLayer)

                let glyphLayer = GlyphLayer(glyph: glyph, font: font, offset: CGPoint(x: ceil(-rect.origin.x), y: ceil(-rect.origin.y)))
                glyphLayer.frame = CGRect(x: rect.minX + position.x, y: rect.minY + position.y + 100, width: ceil(rect.width), height: ceil(rect.height))
                view.layer.addSublayer(glyphLayer)

                print("\(rect) -> \(position)")
                let textLayer = CATextLayer()
                textLayer.foregroundColor = UIColor.red.cgColor
                textLayer.backgroundColor = UIColor.blue.cgColor
                textLayer.string = String(text[textIndex])
                textLayer.font = font
                textIndex = text.index(after: textIndex)
                textLayer.frame = rect.offsetBy(dx: position.x, dy: position.y + 300)
                view.layer.addSublayer(textLayer)
            }
        }

    }
}

