//
//  PreviewViewController.swift
//  TextAnimation
//
//  Created by Sergey V. Krupov on 04.12.2019.
//  Copyright © 2019 Sergey V. Krupov. All rights reserved.
//

import UIKit

final class PreviewViewController: UIViewController, TextSettable {

    // MARK: - Outlets
    @IBOutlet private var animatedStringView: AnimatedStringView!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        animatedStringView.text = "Foo-Bar"
        animatedStringView.addGestureRecognizer(doubleTapRecognizer)
        animatedStringView.addGestureRecognizer(panRecognizer)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? TextSettable {
            destination.setText(animatedStringView.text)
        }
    }

    // MARK: - Action
    @IBAction func previewClickAction(_ sender: Any) {
        animatedStringView.animate()
    }

    @IBAction func unwindToPreview(_ segue: UIStoryboardSegue) {
    }

    // MARK: - PreviewViewControllerProtocol
    func setText(_ text: String?) {
        animatedStringView.text = text
    }

    // MARK: - Private
    var touchPoint: CGPoint?

    private lazy var doubleTapRecognizer: UITapGestureRecognizer = {
        let recognizer = UITapGestureRecognizer()
        recognizer.numberOfTapsRequired = 2
        recognizer.addTarget(self, action: #selector(doubleTapRecognizerAction(_:)))
        return recognizer
    }()

    private lazy var panRecognizer: UIPanGestureRecognizer = {
        let recognizer = UIPanGestureRecognizer()
        recognizer.addTarget(self, action: #selector(panRecognizerAction(_:)))
        return recognizer
    }()

    @objc
    private func doubleTapRecognizerAction(_ recognizer: UITapGestureRecognizer) {
        guard recognizer.state == .recognized else {
            return
        }
        performSegue(withIdentifier: "PresentEditor", sender: self)
    }

    @objc
    private func panRecognizerAction(_ recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            touchPoint = recognizer.location(in: view)
        case .changed:
            if let previousPoint = touchPoint {
                let point = recognizer.location(in: view)

                var origin = animatedStringView.frame.origin
                origin.x += point.x - previousPoint.x
                origin.y += point.y - previousPoint.y
                animatedStringView.frame.origin = origin

                touchPoint = point
            }
        case .ended, .cancelled, .failed:
            touchPoint = nil
        default:
            break
        }
    }
}
