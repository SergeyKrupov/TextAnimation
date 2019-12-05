//
//  AnimatedStringView.swift
//  TextAnimation
//
//  Created by Sergey V. Krupov on 04.12.2019.
//  Copyright © 2019 Sergey V. Krupov. All rights reserved.
//

import UIKit

final class AnimatedStringView: UIView {

    var text: String? {
        get {
            stringLayer.text
        }
        set {
            stringLayer.text = newValue
            bounds.size = stringLayer.bounds.size
        }
    }

    func animate(repeatCount: Int) {
        stringLayer.animate(repeatCount: repeatCount)
    }

    override class var layerClass: AnyClass {
        return AnimatedStringLayer.self
    }

    // MARK: - Private
    private var stringLayer: AnimatedStringLayer {
        layer as! AnimatedStringLayer
    }
}
