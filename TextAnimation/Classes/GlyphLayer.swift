//
//  GlyphLayer.swift
//  TextAnimation
//
//  Created by Sergey V. Krupov on 04.12.2019.
//  Copyright © 2019 Sergey V. Krupov. All rights reserved.
//

import UIKit
              
final class GlyphLayer: CALayer {

    internal init(glyph: CGGlyph, font: CTFont, offset: CGPoint) {
        self.glyph = glyph
        self.font = font
        self.offset = offset
        super.init()
        self.contentsScale = UIScreen.main.scale

        masksToBounds = false
        setNeedsDisplay()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(in ctx: CGContext) {
        ctx.setAllowsAntialiasing(true)
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

    // MARK: - Private
    private let glyph: CGGlyph
    private let font: CTFont
    private let offset: CGPoint
}
