//
//  PreviewViewController.swift
//  TextAnimation
//
//  Created by Sergey V. Krupov on 04.12.2019.
//  Copyright © 2019 Sergey V. Krupov. All rights reserved.
//

import UIKit

final class PreviewViewController: UIViewController {

    @IBOutlet private var animatedStringView: AnimatedStringView!

    override func viewDidLoad() {
        super.viewDidLoad()
        animatedStringView.text = "Foo-Bar"
        animatedStringView.addGestureRecognizer(doubleTapRecognizer)
    }
    
    @IBAction func previewClickAction(_ sender: Any) {
        animatedStringView.animate()
    }

    // MARK: - Private
    private lazy var doubleTapRecognizer: UITapGestureRecognizer = {
        let recognizer = UITapGestureRecognizer()
        recognizer.numberOfTapsRequired = 2
        recognizer.addTarget(self, action: #selector(doubleTapRecognizerAction(_:)))
        return recognizer
    }()

    @objc
    private func doubleTapRecognizerAction(_ recognizer :UITapGestureRecognizer) {
        guard recognizer.state == .recognized else {
            return
        }
        performSegue(withIdentifier: "PresentEditor", sender: self)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
