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
    public static func makeDarkButton(imageName: String? = nil,
                                      handler: (() -> Void)? = nil) -> UIButton {
        var config = UIButton.Configuration.filled()
        
        config.background.backgroundColor = UIColor(named: "Active") ?? .black
        config.cornerStyle = .capsule
        if let imageName {
            config.image = UIImage(named: imageName)
        }
        config.imagePadding = 24
        
        let button = UIButton(configuration: config, primaryAction: UIAction(handler: { _ in
            if let handler { handler() }
        }))
        return button
    }
    
    public static func makeIconicButton(imageName: String,
                                        handler: (() -> Void)? = nil) -> UIButton {
        var config = UIButton.Configuration.plain()
        
        config.image = UIImage(named: imageName)
        config.contentInsets = .zero
        
        let button = UIButton(configuration: config, primaryAction: UIAction(handler: { _ in
            if let handler { handler() }
        }))
        return button
    }
}
