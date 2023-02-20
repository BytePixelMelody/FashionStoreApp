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
        color: UIColor(named: "TitleActive") ?? .black,
        lineHeight: 40,
        letterSpacing: 4
    )
}


