//
//  UIStackView+make.swift
//  FashionStore
//
//  Created by Vyacheslav on 28.03.2023.
//

import UIKit

extension UIStackView {
    
    public static func makeVerticalStackView(
        spacing: Double = 0,
        alignment: UIStackView.Alignment = .fill
    ) -> UIStackView {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .vertical
        stackView.spacing = spacing
        stackView.alignment = alignment
        return stackView
    }
    
    public static func makeHorizontalStackView(
        spacing: Double = 0,
        alignment: UIStackView.Alignment = .fill
    ) -> UIStackView {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .horizontal
        stackView.spacing = spacing
        stackView.alignment = alignment
        return stackView
    }
    
}
