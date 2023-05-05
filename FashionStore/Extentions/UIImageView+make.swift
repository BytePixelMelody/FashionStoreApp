//
//  UIImage+make.swift
//  FashionStore
//
//  Created by Vyacheslav on 08.04.2023.
//

import UIKit
import SnapKit

extension UIImageView {
    
    public static func makeImageView(
        imageName: String,
        width: Double? = nil,
        height: Double? = nil,
        contentMode: UIView.ContentMode? = nil
    ) -> UIImageView {
        let imageView = UIImageView(image: UIImage(named: imageName))

        if let width, let height {
            imageView.snp.makeConstraints { make in
                make.width.equalTo(width)
                make.height.equalTo(height)
            }
        }
        
        if let contentMode {
            imageView.contentMode = contentMode
        }
        
        return imageView
    }
    
}
