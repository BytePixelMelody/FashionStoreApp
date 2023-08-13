//
//  UILabel+make.swift
//  FashionStore
//
//  Created by Vyacheslav on 23.03.2023.
//

import UIKit

extension UILabel {

    static func makeLabel(numberOfLines: Int) -> UILabel {
        let label = UILabel(frame: .zero)
        label.numberOfLines = numberOfLines
        return label
    }

}
