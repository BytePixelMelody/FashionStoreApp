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
        
        // accessibility font scale
        let scaledFont = style.fontMetrics.scaledFont(for: style.font)
        let scaledLineHeight = style.fontMetrics.scaledValue(for: style.lineHeight)
        let scaledLetterSpacing = style.fontMetrics.scaledValue(for: style.letterSpacing)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = scaledLineHeight
        
        let mutableAttributedString = NSMutableAttributedString(
            string: string,
            attributes: [
                .font : scaledFont,
                .foregroundColor : style.color,
                .kern : scaledLetterSpacing,
                .paragraphStyle : paragraphStyle,
                .baselineOffset : (scaledLineHeight - scaledFont.lineHeight) / 4
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
    var letterSpacing: Double
    var fontMetrics: UIFontMetrics
}

extension TextStyle {
    static let titleLarge = TextStyle(
        fontName: "TenorSans",
        size: 18,
        color: UIColor(named: "Active") ?? .black,
        lineHeight: 40,
        letterSpacing: 4,
        fontMetrics: UIFont.TextStyle.title1.metrics
    )
    static let titleMedium = TextStyle(
        fontName: "TenorSans",
        size: 16,
        color: UIColor(named: "Active") ?? .black,
        lineHeight: 24,
        letterSpacing: 3,
        fontMetrics: UIFont.TextStyle.title2.metrics
    )
    static let titleSmall = TextStyle(
        fontName: "TenorSans",
        size: 14,
        color: UIColor(named: "Active") ?? .black,
        lineHeight: 20,
        letterSpacing: 2,
        fontMetrics: UIFont.TextStyle.title3.metrics
    )
    static let bodyLarge = TextStyle(
        fontName: "TenorSans",
        size: 16,
        color: UIColor(named: "Label") ?? .black,
        lineHeight: 24,
        letterSpacing: 0,
        fontMetrics: UIFont.TextStyle.title1.metrics
    )
    static let bodyMedium = TextStyle(
        fontName: "TenorSans",
        size: 14,
        color: UIColor(named: "Label") ?? .black,
        lineHeight: 24,
        letterSpacing: 0,
        fontMetrics: UIFont.TextStyle.title2.metrics
    )
    static let bodySmall = TextStyle(
        fontName: "TenorSans",
        size: 12,
        color: UIColor(named: "Label") ?? .black,
        lineHeight: 18,
        letterSpacing: 0,
        fontMetrics: UIFont.TextStyle.title3.metrics
    )
    static let priceLarge = TextStyle(
        fontName: "TenorSans",
        size: 18,
        color: UIColor(named: "Secondary") ?? .black,
        lineHeight: 24,
        letterSpacing: 0,
        fontMetrics: UIFont.TextStyle.headline.metrics
    )
    static let priceMedium = TextStyle(
        fontName: "TenorSans",
        size: 15,
        color: UIColor(named: "Secondary") ?? .black,
        lineHeight: 24,
        letterSpacing: 0,
        fontMetrics: UIFont.TextStyle.subheadline.metrics
    )
    static let buttonDark = TextStyle(
        fontName: "TenorSans",
        size: 16,
        color: UIColor(named: "OffWhite") ?? .white,
        lineHeight: 26,
        letterSpacing: 0.16, // letter spacing 1% = 16 / 100 * 1
        fontMetrics: UIFont.TextStyle.title1.metrics
    )
}


