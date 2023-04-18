//
//  ModuleBuilder.swift
//  FashionStore
//
//  Created by Vyacheslav on 07.03.2023.
//

import Foundation
import UIKit

protocol ModuleBuilderProtocol {
    func createStoreModule(router: RouterProtocol) -> StoreViewController
    func createProductModule(router: RouterProtocol) -> ProductViewController
    func createCartModule(router: RouterProtocol) -> CartViewController
    func createAddressModule(router: RouterProtocol) -> AddressViewController
    func createPaymentMethodModule(router: RouterProtocol) -> PaymentMethodViewController
    func createCheckoutModule(router: RouterProtocol) -> CheckoutViewController
    func createPurchaseResultModule(router: RouterProtocol, receiptNumber: String) -> PurchaseResultViewController
    func createErrorMessageModule(router: RouterProtocol,
                                errorLabelText: String,
                                errorAction: (() -> Void)?,
                                errorButtonTitle: String?) -> ErrorMessageViewController
    func createTestModule(router: RouterProtocol) -> TestViewController
}

class ModuleBuilder: ModuleBuilderProtocol {
    func createStoreModule(router: RouterProtocol) -> StoreViewController {
        let presenter = StorePresenter(router: router)
        let view = StoreViewController(presenter: presenter)
        presenter.view = view
        return view
    }
    
    func createProductModule(router: RouterProtocol) -> ProductViewController {
        let presenter = ProductPresenter(router: router)
        let view = ProductViewController(presenter: presenter)
        presenter.view = view
        return view
    }
    
    func createCartModule(router: RouterProtocol) -> CartViewController {
        let presenter = CartPresenter(router: router)
        let view = CartViewController(presenter: presenter)
        presenter.view = view
        return view
    }
    
    func createAddressModule(router: RouterProtocol) -> AddressViewController {
        let presenter = AddressPresenter(router: router)
        let view = AddressViewController(presenter: presenter)
        presenter.view = view
        return view
    }
    
    func createPaymentMethodModule(router: RouterProtocol) -> PaymentMethodViewController {
        let presenter = PaymentMethodPresenter(router: router)
        let view = PaymentMethodViewController(presenter: presenter)
        presenter.view = view
        return view
    }
    
    func createCheckoutModule(router: RouterProtocol) -> CheckoutViewController {
        let presenter = CheckoutPresenter(router: router)
        let view = CheckoutViewController(presenter: presenter)
        presenter.view = view
        return view
    }
    
    func createPurchaseResultModule(router: RouterProtocol, receiptNumber: String) -> PurchaseResultViewController {
        let presenter = PurchaseResultPresenter(router: router)
        let view = PurchaseResultViewController(presenter: presenter, receiptNumber: receiptNumber)
        presenter.view = view
        return view
    }
    
    func createErrorMessageModule(router: RouterProtocol,
                                errorLabelText: String,
                                errorAction: (() -> Void)?,
                                errorButtonTitle: String?) -> ErrorMessageViewController {
        let presenter = ErrorMessagePresenter(router: router)
        let view = ErrorMessageViewController(presenter: presenter,
                                       errorLabelText: errorLabelText,
                                       errorAction: errorAction,
                                       errorButtonTitle: errorButtonTitle)
        presenter.view = view
        return view
    }
    
    func createTestModule(router: RouterProtocol) -> TestViewController {
        let presenter = TestPresenter(router: router)
        let view: TestViewController
        view = UIStoryboard(name: "TestStoryboard", bundle: nil)
            .instantiateViewController(identifier: "TestViewController")
        presenter.view = view
        view.presenter = presenter
        return view
    }

}
