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
    
    // show screens
    func showStoreScreen()
    func showProductScreen()
    func showProductScreenInstantly() // for deep link
    func showCartScreen()
    func showAddressScreen()
    func showPaymentMethodScreen()
    func showCheckoutScreen()
    
    func showPopupScreen(
        headerTitle: String,
        message: String,
        subMessage: String?,
        buttonTitle: String,
        buttonAction: (() -> Void)?,
        closeAction: (() -> Void)?,
        image: UIImageView
    )
    
    func showTestScreen()
    
    // close screens
    func dismissScreen() // close modal presented ViewController
    func popScreen() // close screen with standard pop-animation
    func popScreenToBottom() // close screen with to bottom animation
    func popTwoScreensToBottom() // close 2 screens with to bottom animation
    func popToRootScreen() // close all screens with to bottom animation
    
}

class Router: RouterProtocol {
    var navigationController: UINavigationController
    var moduleBuilder: ModuleBuilderProtocol
    
    init(navigationController: UINavigationController, moduleBuilder: ModuleBuilderProtocol) {
        self.navigationController = navigationController
        self.moduleBuilder = moduleBuilder
    }
       
    // MARK: show screens
    
    func showStoreScreen() {
        let viewController = moduleBuilder.createStoreModule(router: self)
        navigationController.setViewControllers([viewController], animated: true)
    }
    
    func showProductScreen() {
        let viewController = moduleBuilder.createProductModule(router: self)
        navigationController.pushViewController(viewController, animated: true)
    }
    
    // show Product screen without animations for deep link use
    func showProductScreenInstantly() {
        let storeViewController: UIViewController?
        if navigationController.viewControllers.count > 0 {
            storeViewController = navigationController.viewControllers.first
        } else {
            storeViewController = moduleBuilder.createStoreModule(router: self)
        }
        guard let storeViewController else { return }
        let productViewController = moduleBuilder.createProductModule(router: self)
        navigationController.setViewControllers([storeViewController, productViewController], animated: false)
    }

    // with animation like modal
    func showCartScreen() {
        let viewController = moduleBuilder.createCartModule(router: self)
        navigationController.view.layer.add(CATransition.toTop, forKey: nil)
        navigationController.pushViewController(viewController, animated: false)
    }
    
    // with animation like modal
    func showCheckoutScreen() {
        let viewController = moduleBuilder.createCheckoutModule(router: self)
        navigationController.view.layer.add(CATransition.toTop, forKey: nil)
        navigationController.pushViewController(viewController, animated: false)
    }
    
    func showAddressScreen() {
        let viewController = moduleBuilder.createAddressModule(router: self)
        navigationController.pushViewController(viewController, animated: true)
   }
    
    func showPaymentMethodScreen() {
        let viewController = moduleBuilder.createPaymentMethodModule(router: self)
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showPopupScreen(
        headerTitle: String,
        message: String,
        subMessage: String?,
        buttonTitle: String,
        buttonAction: (() -> Void)?,
        closeAction: (() -> Void)?,
        image: UIImageView
    ) {
        let viewController = moduleBuilder.createPopupModule(
            router: self,
            headerTitle: headerTitle,
            message: message,
            subMessage: subMessage,
            buttonTitle: buttonTitle,
            buttonAction: buttonAction,
            closeAction: closeAction,
            image: image
        )
        viewController.modalPresentationStyle = .overCurrentContext
        viewController.modalTransitionStyle = .crossDissolve
        navigationController.viewControllers.last?.present(viewController, animated: true)
    }
    
    func showTestScreen() {
        let viewController = moduleBuilder.createTestModule(router: self)
        navigationController.setViewControllers([viewController], animated: true)
    }
    
    // MARK: close screens
    
    // close modal presented ViewController
    func dismissScreen() {
        navigationController.viewControllers.last?.dismiss(animated: true)
    }
        
    // close screen with standard pop-animation
    func popScreen() {
        navigationController.popViewController(animated: true)
    }

    // close screen with "to bottom" animation
    func popScreenToBottom() {
        navigationController.view.layer.add(CATransition.toBottom, forKey: nil)
        navigationController.popViewController(animated: false)
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
    }

    // close all screens
    func popToRootScreen() {
        if navigationController.viewControllers.count > 1 {
            navigationController.popToRootViewController(animated: false)
        }
    }
    
}
