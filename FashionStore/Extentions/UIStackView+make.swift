//
//  UIStackView+make.swift
//  FashionStore
//
//  Created by Vyacheslav on 28.03.2023.
//

import UIKit

extension UIStackView {
    
    public static func makeVerticalStackView() -> UIStackView {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .vertical
        stackView.spacing = 0.0
        return stackView
    }
    
}
