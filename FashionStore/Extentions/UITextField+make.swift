//
//  UITextField+make.swift
//  FashionStore
//
//  Created by Vyacheslav on 20.03.2023.
//

import UIKit

// TODO: make customised UITextField
extension UITextField {
    
    public static func makeHighUnderlinedTextField() -> UITextField {
        let textField = UITextField(frame: .zero)
        
        return textField
    }
    
}

/*
 
 https://developer.apple.com/documentation/uikit/UITextField
 
 class TextFieldWithPadding: UITextField {
     var textPadding = UIEdgeInsets(
         top: 10,
         left: 20,
         bottom: 10,
         right: 20
     )

     override func textRect(forBounds bounds: CGRect) -> CGRect {
         let rect = super.textRect(forBounds: bounds)
         return rect.inset(by: textPadding)
     }

     override func editingRect(forBounds bounds: CGRect) -> CGRect {
         let rect = super.editingRect(forBounds: bounds)
         return rect.inset(by: textPadding)
     }
 }
 https://www.advancedswift.com/uitextfield-with-padding-swift/
 
 */
