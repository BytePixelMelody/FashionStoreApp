//
//  CATransition+animationType.swift
//  Museum
//
//  Created by Vyacheslav on 13.03.2023.
//

import UIKit

// making animations for use with setViewControllers
extension CATransition {
    
    static var toBottom: CATransition {
        let caTransition = CATransition()
        caTransition.duration = 0.45
        caTransition.timingFunction = CAMediaTimingFunction(name: .easeOut)
        caTransition.type = .reveal
        caTransition.subtype = .fromBottom
        return caTransition
    }
    
    static var toTop: CATransition {
        let caTransition = CATransition()
        caTransition.duration = 0.25
        caTransition.timingFunction = CAMediaTimingFunction(name: .easeOut)
        caTransition.type = .moveIn
        caTransition.subtype = .fromTop
        return caTransition
    }
    
    static var systemDefault: CATransition {
        CATransition()
    }
}
