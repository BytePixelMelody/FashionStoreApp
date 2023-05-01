//
//  UITextFieldStyled.swift
//  FashionStore
//
//  Created by Vyacheslav on 28.04.2023.
//

import UIKit

// text field with custom insets and text style
class UITextFieldStyled: UITextField {
    
    // insets from bounds to text
    private let insets: UIEdgeInsets
    // style of text
    private let textStyle: TextStyle
    // style of placeholder
    private let placeholderStyle: TextStyle
    
    init(
        text: String? = nil,
        placeholder: String,
        insets: UIEdgeInsets = UIEdgeInsets(top: 28, left: 0, bottom: 17, right: 0),
        textStyle: TextStyle = .textField,
        placeholderStyle: TextStyle = .placeholder,
        keyboardType: UIKeyboardType = .default,
        returnKeyType: UIReturnKeyType = .default,
        frame: CGRect
    ) {
        self.insets = insets
        self.textStyle = textStyle
        self.placeholderStyle = placeholderStyle
        super.init(frame: frame)
        self.placeholder = placeholder
        self.text = text
        self.keyboardType = keyboardType
        self.returnKeyType = returnKeyType
        
        setupUiTexts()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // apply insets
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.textRect(forBounds: bounds)
        return rect.inset(by: insets)
    }
    
    // apply insets
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.editingRect(forBounds: bounds)
        return rect.inset(by: insets)
    }
    
    private func setupUiTexts() {
        if let placeholder {
            attributedPlaceholder = NSLocalizedString(placeholder, comment: placeholder)
                .setStyle(style: placeholderStyle)
        }
        font = textStyle.fontMetrics.scaledFont(for: textStyle.font)
        textColor = textStyle.color
    }
    
    // accessibility settings was changed - scale fonts
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setupUiTexts()
    }
   
}
