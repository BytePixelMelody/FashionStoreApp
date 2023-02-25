//
//  CATransitions+types.swift
//  FashionStore
//
//  Created by Vyacheslav on 25.02.2023.
//

import UIKit

// making animations for show UIViewControllers
extension CATransition {
    
    static var fromLeft: CATransition {
        let caTransition = CATransition()
        caTransition.subtype = .fromLeft
        caTransition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        caTransition.type = CATransitionType.moveIn
        return caTransition
    }
    
    static var fromRight: CATransition {
        let caTransition = CATransition()
        caTransition.subtype = .fromRight
        caTransition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        caTransition.type = CATransitionType.moveIn
        return caTransition
    }
    
    static var systemDefault: CATransition {
        CATransition()
    }
}
