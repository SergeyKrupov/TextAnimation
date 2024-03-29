//
//  EditViewController.swift
//  TextAnimation
//
//  Created by Sergey V. Krupov on 04.12.2019.
//  Copyright © 2019 Sergey V. Krupov. All rights reserved.
//

import UIKit

final class EditViewController: UIViewController, TextSettable {

    // MARK: - Outlets
    @IBOutlet private var textField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        textField.text = initialText
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? TextSettable {
            destination.setText(textField.text)
        }
    }

    // MARK: - EditorViewControllerProtocol
    func setText(_ text: String?) {
        initialText = text
    }

    // MARK: - Private
    private var initialText: String?
}

