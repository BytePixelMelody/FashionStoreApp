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
        paragraphStyle.alignment = style.alignment
        
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
    var fontName: String = "TenorSans"
    var size: Double
    var color: UIColor
    var lineHeight: Double
    var letterSpacing: Double = 0.0
    var fontMetrics: UIFontMetrics
    var alignment: NSTextAlignment = .left
}

extension TextStyle {
    static let titleLargeAlignLeft = TextStyle(
        size: 18,
        color: UIColor(named: "Active") ?? .black,
        lineHeight: 40,
        letterSpacing: 4,
        fontMetrics: UIFont.TextStyle.title1.metrics
    )
    static let titleLargeAlignCenter = TextStyle(
        size: 18,
        color: UIColor(named: "Active") ?? .black,
        lineHeight: 40,
        letterSpacing: 4,
        fontMetrics: UIFont.TextStyle.title1.metrics,
        alignment: .center
    )
    static let titleMedium = TextStyle(
        size: 16,
        color: UIColor(named: "Active") ?? .black,
        lineHeight: 24,
        letterSpacing: 3,
        fontMetrics: UIFont.TextStyle.title2.metrics
    )
    static let titleSmall = TextStyle(
        size: 14,
        color: UIColor(named: "Active") ?? .black,
        lineHeight: 20,
        letterSpacing: 2,
        fontMetrics: UIFont.TextStyle.title3.metrics
    )
    static let bodyLarge = TextStyle(
        size: 16,
        color: UIColor(named: "Label") ?? .black,
        lineHeight: 24,
        fontMetrics: UIFont.TextStyle.title1.metrics
    )
    static let bodyLargeAlignCenter = TextStyle(
        size: 16,
        color: UIColor(named: "Label") ?? .black,
        lineHeight: 24,
        fontMetrics: UIFont.TextStyle.title1.metrics,
        alignment: .center
    )
    static let bodyMedium = TextStyle(
        size: 14,
        color: UIColor(named: "Label") ?? .black,
        lineHeight: 24,
        fontMetrics: UIFont.TextStyle.title2.metrics
    )
    static let bodySmall = TextStyle(
        size: 12,
        color: UIColor(named: "Label") ?? .black,
        lineHeight: 18,
        fontMetrics: UIFont.TextStyle.title3.metrics
    )
    static let priceLarge = TextStyle(
        size: 18,
        color: UIColor(named: "Secondary") ?? .brown,
        lineHeight: 24,
        fontMetrics: UIFont.TextStyle.headline.metrics
    )
    static let priceMedium = TextStyle(
        size: 15,
        color: UIColor(named: "Secondary") ?? .brown,
        lineHeight: 24,
        fontMetrics: UIFont.TextStyle.subheadline.metrics
    )
    static let priceTotal = TextStyle(
        size: 16,
        color: UIColor(named: "Secondary") ?? .brown,
        lineHeight: 20,
        letterSpacing: 3,
        fontMetrics: UIFont.TextStyle.title3.metrics
    )
    static let buttonDark = TextStyle(
        size: 16,
        color: UIColor(named: "OffWhite") ?? .white,
        lineHeight: 20,
        letterSpacing: 0.16, // letter spacing 1% = 16 / 100 * 1
        fontMetrics: UIFont.TextStyle.title1.metrics
    )
    static let subHeader = TextStyle(
        size: 14,
        color: UIColor(named: "Placeholder") ?? .gray,
        lineHeight: 16,
        letterSpacing: 1,
        fontMetrics: UIFont.TextStyle.title2.metrics
    )
    static let placeholder = TextStyle(
        size: 15,
        color: UIColor(named: "PlaceholderLight") ?? .gray,
        lineHeight: 18,
        fontMetrics: UIFont.TextStyle.title2.metrics
    )
    static let addressUserName = TextStyle(
        size: 18,
        color: UIColor(named: "Active") ?? .black,
        lineHeight: 22,
        fontMetrics: UIFont.TextStyle.headline.metrics
    )
    static let address = TextStyle(
        size: 14,
        color: UIColor(named: "Label") ?? .black,
        lineHeight: 22,
        fontMetrics: UIFont.TextStyle.headline.metrics
    )
}


