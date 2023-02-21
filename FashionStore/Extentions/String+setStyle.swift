//
//  String+setStyle.swift
//  FashionStore
//
//  Created by Vyacheslav on 19.02.2023.
//

import UIKit

extension String {
    public func setStyle(style: TextStyle) -> NSMutableAttributedString {
        let string = self
        
        let paragraphStyle = NSMutableParagraphStyle()
        // style.lineHeight - Figma's space between top and top of two lines
        // style.font.lineHeight - standard space between top and top of two lines
        // lineHeightMultiple - multiplier to standard value
        let lineHeightMultiple = style.lineHeight / style.font.lineHeight
        paragraphStyle.lineHeightMultiple = lineHeightMultiple
        //paragraphStyle.alignment = .center
        
        let mutableAttributedString = NSMutableAttributedString(
            string: string,
            attributes: [
                .font : style.font,
                .foregroundColor : style.color,
                .kern : style.letterSpacing,
                .paragraphStyle : paragraphStyle,
            ]
        )
        
        return mutableAttributedString
    }
}

public struct TextStyle {
    var font: UIFont {
        UIFont(name: fontName, size: size) ?? .systemFont(ofSize: size)
    }
    var fontName: String
    var size: Double
    var color: UIColor
    var lineHeight: Double
    var letterSpacing: Int
}

extension TextStyle {
    static let titleLarge = TextStyle(
        fontName: "TenorSans",
        size: 18,
        color: UIColor(named: "Active") ?? .black,
        lineHeight: 40,
        letterSpacing: 4
    )
    static let titleMedium = TextStyle(
        fontName: "TenorSans",
        size: 16,
        color: UIColor(named: "Active") ?? .black,
        lineHeight: 24,
        letterSpacing: 3
    )
    static let titleSmall = TextStyle(
        fontName: "TenorSans",
        size: 14,
        color: UIColor(named: "Active") ?? .black,
        lineHeight: 20,
        letterSpacing: 2
    )
    static let bodyLarge = TextStyle(
        fontName: "TenorSans",
        size: 16,
        color: UIColor(named: "Label") ?? .black,
        lineHeight: 24,
        letterSpacing: 0
    )
    static let bodyMedium = TextStyle(
        fontName: "TenorSans",
        size: 14,
        color: UIColor(named: "Label") ?? .black,
        lineHeight: 24,
        letterSpacing: 0
    )
    static let bodySmall = TextStyle(
        fontName: "TenorSans",
        size: 12,
        color: UIColor(named: "Label") ?? .black,
        lineHeight: 18,
        letterSpacing: 0
    )
    static let priceLarge = TextStyle(
        fontName: "TenorSans",
        size: 18,
        color: UIColor(named: "Secondary") ?? .black,
        lineHeight: 24,
        letterSpacing: 0
    )
    static let priceMedium = TextStyle(
        fontName: "TenorSans",
        size: 15,
        color: UIColor(named: "Secondary") ?? .black,
        lineHeight: 24,
        letterSpacing: 0
    )
}


