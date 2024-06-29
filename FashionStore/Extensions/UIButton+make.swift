//
//  UIButton+make.swift
//  FashionStore
//
//  Created by Vyacheslav on 07.03.2023.
//

import UIKit

// button factory
extension UIButton {

    static func makeDarkButton(
        imageName: String? = nil,
        action: (() -> Void)? = nil
    ) -> UIButton {
        var config = UIButton.Configuration.filled()

        config.background.backgroundColor = .active
        config.cornerStyle = .capsule
        if let imageName {
            config.image = UIImage(named: imageName)
        }
        config.imagePadding = 24

        let button = UIButton(configuration: config, primaryAction: UIAction { _ in action?() })

        return button
    }

    static func makeIconicButton(
        imageName: String? = nil,
        action: (() -> Void)? = nil
    ) -> UIButton {
        var config = UIButton.Configuration.plain()

        if let imageName {
            config.image = UIImage(named: imageName)
        }
        config.contentInsets = .zero

        let button = UIButton(configuration: config, primaryAction: UIAction { _ in action?() })

        return button
    }

    static func makeGrayCapsuleButton(
        imageName: String? = nil,
        action: (() -> Void)? = nil) -> UIButton {
        var config = UIButton.Configuration.filled()

            config.background.backgroundColor = .inputBackground
        config.cornerStyle = .capsule
        if let imageName {
            config.image = UIImage(named: imageName)
        }

        config.imagePlacement = .trailing

        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)

        let button = UIButton(configuration: config, primaryAction: UIAction { _ in action?() })

        button.contentHorizontalAlignment = .leading

        button.imageView?.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }

        return button
    }

}
