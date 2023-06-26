//
//  ContainerView.swift
//  FashionStore
//
//  Created by Vyacheslav on 07.04.2023.
//

import UIKit
import SnapKit

final class ContainerView: UIView {
    
    private var subView: UIView?
    
    public func setSubView(_ newView: UIView) {
        // removing an old view
        if let oldView = subView {
            oldView.removeFromSuperview()
        }
        
        // adding and arranging a new view
        self.addSubview(newView)
        newView.snp.makeConstraints { make in
            make.margins.equalToSuperview()
        }
        
        // storing a link to the view
        subView = newView
    }
    
}
