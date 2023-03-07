//
//  UIButton+make.swift
//  FashionStore
//
//  Created by Vyacheslav on 07.03.2023.
//

import Foundation
import UIKit

// button factory
extension UIButton {
    public static func makeButtonDark(text: String) -> UIButton {
        var config = UIButton.Configuration.filled()
        
        config.attributedTitle = AttributedString(text.setStyle(style: .buttonDark))
        config.background.backgroundColor = UIColor(named: "Active") ?? .black
        config.background.cornerRadius = 0
        
        let button = UIButton(configuration: config)
        return button
    }
}
