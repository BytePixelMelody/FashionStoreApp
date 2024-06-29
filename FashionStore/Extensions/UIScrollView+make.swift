//
//  UIScrollView+make.swift
//  FashionStore
//
//  Created by Vyacheslav on 28.03.2023.
//

import UIKit

extension UIScrollView {

    static func makeScrollView() -> UIScrollView {
        let scrollView = UIScrollView(frame: .zero)
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        // hide keyboard on any scroll gesture
        scrollView.keyboardDismissMode = .onDrag
        return scrollView
    }

}
