//
//  BouncePositionAnimation.swift
//  TextAnimation
//
//  Created by Sergey V. Krupov on 04.12.2019.
//  Copyright © 2019 Sergey V. Krupov. All rights reserved.
//

import UIKit

// Упрощённый вариант анимации от сюда https://www.objc.io/issues/12-animations/animations-explained/

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

    override var values: [Any]? {
        get {
            let count = Int(duration * 60)
            return (0 ... count)
                .map { CFTimeInterval($0) / 60.0 }
                .map(evaluate)
        }
        set {
            fatalError("BouncePositionAnimation не поддерживает установку значения свойства values")
        }
    }

    // MARK: - Private
    private let fromValue: CGPoint
    private let toValue: CGPoint

    private func evaluate(moment: CFTimeInterval) -> CGPoint {
        let fraction = easeOutBounce(moment / duration)
        return CGPoint(
            x: Double(fromValue.x) + Double(toValue.x - fromValue.x) * fraction,
            y: Double(fromValue.y) + Double(toValue.y - fromValue.y) * fraction
        )
    }

    private func easeOutBounce(_ t: Double) -> Double {
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
