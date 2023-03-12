//
//  ViewController.swift
//  FashionStore
//
//  Created by Vyacheslav on 17.02.2023.
//

import UIKit
import SnapKit

protocol TestViewProtocol: AnyObject {
    
}

class TestViewController: UIViewController {
    private static let labelText = "Test\nView\nController"
    
    @IBOutlet private var label: UILabel!
    
    var presenter: TestPresenterProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fillByStyledText()
    }
    
    public func fillByStyledText() {
        label.attributedText = Self.labelText.uppercased().setStyle(style: .titleLargeAlignLeft)
    }

    // accessibility font scale on the fly
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        fillByStyledText()
    }
}

extension TestViewController: TestViewProtocol {
    
}
