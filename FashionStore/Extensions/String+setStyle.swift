//
//  String+setStyle.swift
//  FashionStore
//
//  Created by Vyacheslav on 19.02.2023.
//

import UIKit

extension String {
    func setStyle(style: TextStyle) -> NSMutableAttributedString {
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
                .font: scaledFont,
                .foregroundColor: style.color,
                .kern: scaledLetterSpacing,
                .paragraphStyle: paragraphStyle,
                .baselineOffset: (scaledLineHeight - scaledFont.lineHeight) / 4
            ]
        )

        return mutableAttributedString
    }
}

struct TextStyle {
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
        color: .active,
        lineHeight: 24,
        letterSpacing: 4,
        fontMetrics: UIFont.TextStyle.largeTitle.metrics
    )
    static let titleLargeAlignCentered = TextStyle(
        size: 18,
        color: .active,
        lineHeight: 24,
        letterSpacing: 4,
        fontMetrics: UIFont.TextStyle.largeTitle.metrics,
        alignment: .center
    )
    static let titleMedium = TextStyle(
        size: 16,
        color: .active,
        lineHeight: 19,
        letterSpacing: 3,
        fontMetrics: UIFont.TextStyle.title1.metrics
    )
    static let titleSmall = TextStyle(
        size: 14,
        color: .active,
        lineHeight: 16,
        letterSpacing: 2,
        fontMetrics: UIFont.TextStyle.title2.metrics
    )
    static let titleSmallHight = TextStyle(
        size: 14,
        color: .active,
        lineHeight: 20,
        letterSpacing: 2,
        fontMetrics: UIFont.TextStyle.title2.metrics
    )
    static let bodyLarge = TextStyle(
        size: 16,
        color: .graphite,
        lineHeight: 19,
        fontMetrics: UIFont.TextStyle.title1.metrics
    )
    static let bodyLargeAlignCentered = TextStyle(
        size: 16,
        color: .graphite,
        lineHeight: 24,
        fontMetrics: UIFont.TextStyle.title1.metrics,
        alignment: .center
    )
    static let bodyMedium = TextStyle(
        size: 14,
        color: .graphite,
        lineHeight: 24,
        fontMetrics: UIFont.TextStyle.title2.metrics
    )
    static let bodySmallActive = TextStyle(
        size: 12,
        color: .active,
        lineHeight: 15,
        fontMetrics: UIFont.TextStyle.title3.metrics
    )
    static let bodySmallLabel = TextStyle(
        size: 12,
        color: .graphite,
        lineHeight: 14,
        fontMetrics: UIFont.TextStyle.title3.metrics
    )
    static let bodySmallLabelHight = TextStyle(
        size: 12,
        color: .graphite,
        lineHeight: 18,
        fontMetrics: UIFont.TextStyle.title3.metrics
    )
    static let priceLarge = TextStyle(
        size: 18,
        color: .nutty,
        lineHeight: 21,
        fontMetrics: UIFont.TextStyle.largeTitle.metrics
    )
    static let priceMedium = TextStyle(
        size: 15,
        color: .nutty,
        lineHeight: 24,
        fontMetrics: UIFont.TextStyle.title1.metrics
    )
    static let priceTotal = TextStyle(
        size: 16,
        color: .nutty,
        lineHeight: 20,
        letterSpacing: 3,
        fontMetrics: UIFont.TextStyle.title1.metrics
    )
    static let buttonDark = TextStyle(
        size: 16,
        color: .offWhite,
        lineHeight: 20,
        letterSpacing: 0.16, // letter spacing 1% = 16 / 100 * 1
        fontMetrics: UIFont.TextStyle.largeTitle.metrics
    )
    static let subHeader = TextStyle(
        size: 14,
        color: .placeholder,
        lineHeight: 16,
        letterSpacing: 1,
        fontMetrics: UIFont.TextStyle.title2.metrics
    )
    static let placeholder = TextStyle(
        size: 15,
        color: .placeholderLight,
        lineHeight: 18,
        fontMetrics: UIFont.TextStyle.title1.metrics
    )
    static let textField = TextStyle(
        size: 15,
        color: .active,
        lineHeight: 18,
        fontMetrics: UIFont.TextStyle.title1.metrics
    )
    static let infoLarge = TextStyle(
        size: 18,
        color: .active,
        lineHeight: 22,
        fontMetrics: UIFont.TextStyle.largeTitle.metrics
    )
    static let infoLargeCentered = TextStyle(
        size: 18,
        color: .active,
        lineHeight: 22,
        fontMetrics: UIFont.TextStyle.largeTitle.metrics,
        alignment: .center
    )
    static let address = TextStyle(
        size: 14,
        color: .graphite,
        lineHeight: 22,
        fontMetrics: UIFont.TextStyle.title2.metrics
    )
    static let bodyMediumDark = TextStyle(
        size: 14,
        color: .active,
        lineHeight: 16,
        fontMetrics: UIFont.TextStyle.title2.metrics
    )
    static let numberMediumDark = TextStyle(
        size: 14,
        color: .active,
        lineHeight: 14,
        fontMetrics: UIFont.TextStyle.title2.metrics
    )
    static let activeMediumCentered = TextStyle(
        size: 15,
        color: .graphite,
        lineHeight: 22,
        fontMetrics: UIFont.TextStyle.title1.metrics,
        alignment: .center
    )
}
