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

    // MARK: - Private
    private struct Glyph {
        let layer: GlyphLayer
        let frame: CGRect
    }

    private var glyphs: [Glyph] = []

    private func rebuildSublayers() {
        glyphs.forEach {
            $0.layer.removeFromSuperlayer()
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
            glyphs.append(Glyph(layer: layer, frame: layer.frame))
        }
        bounds.size = boundingRect.size
    }
}