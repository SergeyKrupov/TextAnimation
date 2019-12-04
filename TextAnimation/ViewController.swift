//
//  ViewController.swift
//  TextAnimation
//
//  Created by Sergey V. Krupov on 03.12.2019.
//  Copyright © 2019 Sergey V. Krupov. All rights reserved.
//

import UIKit

final class ViewController: UIViewController {

    @IBAction func start(_ sender: Any) {
        animatedString.animate()
    }

    private lazy var animatedString: AnimatedStringLayer = {
        let layer = AnimatedStringLayer()
        layer.text = "Blah-blah-blah😎"
        layer.frame.origin = CGPoint(x: 20, y: 200)
        return layer
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.addSublayer(animatedString)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}
