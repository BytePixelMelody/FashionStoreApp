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
        imageName: String? = nil,
        width: Double? = nil,
        height: Double? = nil,
        contentMode: UIView.ContentMode? = nil,
        cornerRadius: Double = 0,
        clipsToBounds: Bool = false
    ) -> UIImageView {
        let imageView: UIImageView
        
        if let imageName {
            imageView = UIImageView(image: UIImage(named: imageName))
        } else {
            imageView = UIImageView(frame: .zero)
        }
        
        if let width, let height {
            imageView.snp.makeConstraints { make in
                make.width.equalTo(width)
                make.height.equalTo(height)
            }
        }
        
        if let contentMode {
            imageView.contentMode = contentMode
        }
        
        imageView.layer.cornerRadius = cornerRadius
        imageView.clipsToBounds = clipsToBounds
        
        return imageView
    }
    
}
