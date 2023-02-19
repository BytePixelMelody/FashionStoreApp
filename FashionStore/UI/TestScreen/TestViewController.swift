//
//  ViewController.swift
//  FashionStore
//
//  Created by Vyacheslav on 17.02.2023.
//

import UIKit

class TestViewController: UIViewController {
    
    @IBOutlet var label: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let attributedString = NSAttributedString(
            string: "Fashion\nStore",
            attributes: [
                .font: UIFont(name: "TenorSans", size: 22) ?? UIFont.systemFont(ofSize: 22),
                .foregroundColor: UIColor.black,
            ]
        )
        label.attributedText = attributedString
        
    }
}

