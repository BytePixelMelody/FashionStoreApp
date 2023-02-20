//
//  ViewController.swift
//  FashionStore
//
//  Created by Vyacheslav on 17.02.2023.
//

import UIKit

class TestViewController: UIViewController {
    
    @IBOutlet var label: UILabel!
    let labelText = "TITLE \nUppercase"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        label.attributedText = labelText.uppercased().setStyle(style: .titleLarge)
        
    }
}

