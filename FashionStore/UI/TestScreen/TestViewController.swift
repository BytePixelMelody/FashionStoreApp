//
//  ViewController.swift
//  FashionStore
//
//  Created by Vyacheslav on 17.02.2023.
//

import UIKit

class TestViewController: UIViewController {
    
    @IBOutlet var label: UILabel!
    let labelText = "TITLE\nUppercase"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        fillByStyledText()
    }
    
    public func fillByStyledText() {
        label.attributedText = labelText.uppercased().setStyle(style: .titleLarge)
    }

    // accessibility font scale on the fly
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        fillByStyledText()
    }
}

