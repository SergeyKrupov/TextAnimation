//
//  PreviewViewController.swift
//  TextAnimation
//
//  Created by Sergey V. Krupov on 04.12.2019.
//  Copyright © 2019 Sergey V. Krupov. All rights reserved.
//

import UIKit

protocol PreviewViewControllerProtocol {

    func setText(_ text: String?)
}

final class PreviewViewController: UIViewController, PreviewViewControllerProtocol {

    // MARK: - Outlets
    @IBOutlet private var animatedStringView: AnimatedStringView!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        animatedStringView.text = "Foo-Bar"
        animatedStringView.addGestureRecognizer(doubleTapRecognizer)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.description as? EditorViewControllerProtocol {
            destination.setText(animatedStringView.text)
        }
    }

    // MARK: - Action
    @IBAction func previewClickAction(_ sender: Any) {
        animatedStringView.animate()
    }

    // MARK: - PreviewViewControllerProtocol
    func setText(_ text: String?) {
        animatedStringView.text = text
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
}
