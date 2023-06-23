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
    
    var presenter: TestPresenterProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fillByStyledText()
    }
    
    public func fillByStyledText() {
        label.attributedText = Self.labelText.uppercased().setStyle(style: .titleLargeAlignLeft)
    }

    // accessibility settings was changed - scale fonts
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.preferredContentSizeCategory != previousTraitCollection?.preferredContentSizeCategory {
            fillByStyledText()
        }
    }
    
}

extension TestViewController: TestViewProtocol {
    
}
