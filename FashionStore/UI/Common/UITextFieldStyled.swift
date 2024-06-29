//
//  UITextFieldStyled.swift
//  FashionStore
//
//  Created by Vyacheslav on 28.04.2023.
//

import UIKit

// text field with custom insets and text style
final class UITextFieldStyled: UITextField {

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
        isSecureTextEntry: Bool = false,
        dataIsSensitive: Bool = false, // MASVS (Mobile Application Security Verification Standard)
        frame: CGRect = .zero
    ) {
        self.insets = insets
        self.textStyle = textStyle
        self.placeholderStyle = placeholderStyle
        super.init(frame: frame)
        self.placeholder = placeholder
        self.text = text
        self.keyboardType = keyboardType
        self.returnKeyType = returnKeyType
        self.isSecureTextEntry = isSecureTextEntry
        if dataIsSensitive { // MASVS (Mobile Application Security Verification Standard) - turn off keyboard cache
            self.autocorrectionType = .no
            self.autocapitalizationType = .none
            self.spellCheckingType = .no
        }

        // clear button
        clearButtonMode = .whileEditing

        setupUiTexts()
        registerFontScaling()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var placeholder: String? {
        get {
            super.placeholder
        }
        set {
            super.placeholder = newValue
            attributedPlaceholder = newValue?.setStyle(style: placeholderStyle)
        }
    }

    private func setupUiTexts() {
        // placeholder style
        attributedPlaceholder = placeholder?.setStyle(style: placeholderStyle)

        // text style
        font = textStyle.fontMetrics.scaledFont(for: textStyle.font)
        textColor = textStyle.color
    }

    // accessibility settings was changed - scale fonts
    private func registerFontScaling() {
        registerForTraitChanges([UITraitPreferredContentSizeCategory.self]) { (self: Self, previousTraitCollection: UITraitCollection) in
            if self.traitCollection.preferredContentSizeCategory != previousTraitCollection.preferredContentSizeCategory {
                self.setupUiTexts()
            }
        }
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

    override func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
        var clearButtonRect = super.clearButtonRect(forBounds: bounds)
        // centerY shift calculation
        let clearButtonCenterY = clearButtonRect.minY + clearButtonRect.height / 2
        let textFieldShiftedCenterY = insets.top + (frame.height - insets.top - insets.bottom) / 2
        // changing of clearButton start point with shift
        let shiftY = textFieldShiftedCenterY - clearButtonCenterY

        let clearButtonNewOrigin = CGPoint(x: clearButtonRect.origin.x, y: clearButtonRect.origin.y + shiftY)
        clearButtonRect.origin = clearButtonNewOrigin
        return clearButtonRect
    }

}
