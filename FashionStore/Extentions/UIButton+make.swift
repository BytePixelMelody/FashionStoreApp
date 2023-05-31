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
                                      action: (() -> Void)? = nil) -> UIButton {
        var config = UIButton.Configuration.filled()
        
        config.background.backgroundColor = UIColor(named: "Active") ?? .black
        config.cornerStyle = .capsule
        if let imageName {
            config.image = UIImage(named: imageName)
        }
        config.imagePadding = 24
        
        let button = UIButton(configuration: config, primaryAction: UIAction(handler: { _ in
            if let action { action() } 
        }))
        return button
    }
    
    public static func makeIconicButton(imageName: String? = nil,
                                        action: (() -> Void)? = nil) -> UIButton {
        var config = UIButton.Configuration.plain()
        
        if let imageName {
            config.image = UIImage(named: imageName)
        }
        config.contentInsets = .zero
        
        let button: UIButton
        
        if let action {
            button = UIButton(configuration: config, primaryAction: UIAction(handler: { _ in action() }))
        } else {
            button = UIButton(configuration: config)
        }
        return button
    }
    
    public static func makeGrayCapsuleButton(imageName: String? = nil,
                                      action: (() -> Void)? = nil) -> UIButton {
        var config = UIButton.Configuration.filled()

        config.background.backgroundColor = UIColor(named: "InputBackground") ?? .systemGray6
        config.cornerStyle = .capsule
        if let imageName {
            config.image = UIImage(named: imageName)
        }

        config.imagePlacement = .trailing

        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)

        let button = UIButton(configuration: config, primaryAction: UIAction(handler: { _ in
            if let action { action() }
        }))

        button.contentHorizontalAlignment = .leading
        
        button.imageView?.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }

        return button
    }

}
