//
//  Router.swift
//  FashionStore
//
//  Created by Vyacheslav on 07.03.2023.
//

import Foundation
import UIKit

protocol RouterProtocol {
    var navigationController: UINavigationController { get set }
    var moduleBuilder: ModuleBuilderProtocol { get set }
    
    func popScreen() // close screen with standard animation
    func popScreenToBottom() // close screen with to bottom animation
    func popTwoScreensToBottom() // close 2 screen with to bottom animation
    func showStoreScreen()
    func showProductScreen()
    func showCartScreen()
    func showAddressScreen()
    func showPaymentMethodScreen()
    func showCheckoutScreen()
    func showTestScreen()
}

class Router: RouterProtocol {
    var navigationController: UINavigationController
    var moduleBuilder: ModuleBuilderProtocol
    
    init(navigationController: UINavigationController, moduleBuilder: ModuleBuilderProtocol) {
        self.navigationController = navigationController
        self.moduleBuilder = moduleBuilder
    }
    
    // close screen
    func popScreen() {
        navigationController.popViewController(animated: true)
    }

    // close screen with "to bottom" animation
    func popScreenToBottom() {
        navigationController.view.layer.add(CATransition.toBottom, forKey: nil)
        navigationController.popViewController(animated: false)
        
        // turn on navigation swipes
        navigationController.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    // close two screens with "to bottom" animation
    func popTwoScreensToBottom() {
        // remove penultimate screen
        let countViewControllers = navigationController.viewControllers.count
        guard countViewControllers > 2 else { return }
        navigationController.viewControllers.remove(at: countViewControllers - 2)
        
        // close last screen
        navigationController.view.layer.add(CATransition.toBottom, forKey: nil)
        navigationController.popViewController(animated: false)
        
        // turn on navigation swipes
        navigationController.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    func showStoreScreen() {
        let viewController = moduleBuilder.createStoreModule(router: self)
        navigationController.setViewControllers([viewController], animated: true)
    }
    
    func showProductScreen() {
        let viewController = moduleBuilder.createProductModule(router: self)
        navigationController.pushViewController(viewController, animated: true)
    }

    // screen will be presented with animation like modal
    func showCartScreen() {
        let viewController = moduleBuilder.createCartModule(router: self)
        navigationController.view.layer.add(CATransition.toTop, forKey: nil)
        navigationController.pushViewController(viewController, animated: false)
        
        // turn off navigation swipes
        navigationController.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    // screen will be presented with animation like modal
    func showCheckoutScreen() {
        let viewController = moduleBuilder.createCheckoutModule(router: self)
        navigationController.view.layer.add(CATransition.toTop, forKey: nil)
        navigationController.pushViewController(viewController, animated: false)
        
        // turn off navigation swipes
        navigationController.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    func showAddressScreen() {
        let viewController = moduleBuilder.createAddressModule(router: self)
        navigationController.setViewControllers([viewController], animated: true)
    }
    
    func showPaymentMethodScreen() {
        let viewController = moduleBuilder.createPaymentMethodModule(router: self)
        navigationController.setViewControllers([viewController], animated: true)
    }
    
    func showTestScreen() {
        let viewController = moduleBuilder.createTestModule(router: self)
        navigationController.setViewControllers([viewController], animated: true)
    }
    
}
