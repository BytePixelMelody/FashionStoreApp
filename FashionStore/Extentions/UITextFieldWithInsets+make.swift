//
//  UITextField+make.swift
//  FashionStore
//
//  Created by Vyacheslav on 20.03.2023.
//

import UIKit

// text field with custom insets
class UITextFieldWithInsets: UITextField {
    
    private var textInsets: UIEdgeInsets
    
    init(textInsets: UIEdgeInsets, frame: CGRect) {
        self.textInsets = textInsets
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.textRect(forBounds: bounds)
        return rect.inset(by: textInsets)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.editingRect(forBounds: bounds)
        return rect.inset(by: textInsets)
    }
    
}

// TODO: make customised UITextField with height 64px and 1px line

// factory of UITextFieldWithInsets
extension UITextFieldWithInsets {
    
    static func makeTextFieldWithInsets(textInsets: UIEdgeInsets) -> UITextFieldWithInsets {
        let textField = UITextFieldWithInsets(textInsets: textInsets, frame: .zero)
        
        textField.autocorrectionType = .no
        
        // functions are declared in extension to String
//        textField.defaultTextAttributes[.font] = TextStyle.bodyLarge.font
        textField.defaultTextAttributes[.foregroundColor] = TextStyle.bodyLarge.color
        
        return textField
    }
    
}


