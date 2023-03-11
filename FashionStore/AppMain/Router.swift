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
    
    func popScreen()
    func dismissScreen()
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
    
    func popScreen() {
        navigationController.popViewController(animated: true)
    }
    
    func dismissScreen() {
        navigationController.dismiss(animated: true)
    }
    
    func showStoreScreen() {
        let viewController = moduleBuilder.createStoreModule(router: self)
        navigationController.setViewControllers([viewController], animated: true)
    }
    
    func showProductScreen() {
        let viewController = moduleBuilder.createProductModule(router: self)
        navigationController.pushViewController(viewController, animated: true)
    }

    func showCartScreen() {
        let viewController = moduleBuilder.createCartModule(router: self)
        viewController.modalPresentationStyle = .fullScreen
        navigationController.present(viewController, animated: true)
    }
    
    func showAddressScreen() {
        let viewController = moduleBuilder.createAddressModule(router: self)
        navigationController.setViewControllers([viewController], animated: true)
    }
    
    func showPaymentMethodScreen() {
        let viewController = moduleBuilder.createPaymentMethodModule(router: self)
        navigationController.setViewControllers([viewController], animated: true)
    }
    
    func showCheckoutScreen() {
        let viewController = moduleBuilder.createCheckoutModule(router: self)
        navigationController.setViewControllers([viewController], animated: true)
    }
    
    func showTestScreen() {
        let viewController = moduleBuilder.createTestModule(router: self)
        navigationController.setViewControllers([viewController], animated: true)
    }
    
}
