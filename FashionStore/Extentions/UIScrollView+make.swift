//
//  UIScrollView+make.swift
//  FashionStore
//
//  Created by Vyacheslav on 28.03.2023.
//

import UIKit

extension UIScrollView {
    
    public static func makeScrollView() -> UIScrollView {
        let scrollView = UIScrollView(frame: .zero)
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }
    
}
