//
//  ModuleBuilder.swift
//  FashionStore
//
//  Created by Vyacheslav on 07.03.2023.
//

import Foundation
import UIKit

protocol ModuleBuilding {
    func createStoreModule(router: Routing) -> StoreViewController
    func createProductModule(router: Routing, product: Product, image: UIImage?) -> ProductViewController
    func createCartModule(router: Routing) -> CartViewController
    func createAddressModule(router: Routing) -> AddressViewController
    func createPaymentMethodModule(router: Routing) -> PaymentMethodViewController
    func createCheckoutModule(router: Routing) -> CheckoutViewController
    
    func createPopupModule(
        router: Routing,
        headerTitle: String,
        message: String,
        subMessage: String?,
        buttonTitle: String,
        buttonAction: (() -> Void)?,
        closeAction: (() -> Void)?,
        image: UIImageView
    ) -> PopupViewController
        
    func createTestModule(router: Routing) -> TestViewController
}

final class ModuleBuilder: ModuleBuilding {
    
    private let keychainService = KeychainService()
    private let webService: WebServiceProtocol
    private let coreDataService: CoreDataServiceProtocol
    
    init(coreDataService: CoreDataServiceProtocol, webService: WebServiceProtocol) {
        self.coreDataService = coreDataService
        self.webService = webService
    }
    
    func createStoreModule(router: Routing) -> StoreViewController {
        let presenter = StorePresenter(
            router: router,
            webService: webService,
            coreDataService: coreDataService
        )
        let view = StoreViewController(presenter: presenter)
        presenter.view = view
        return view
    }
    
    func createProductModule(
        router: Routing,
        product: Product,
        image: UIImage?
    ) -> ProductViewController {
        let presenter = ProductPresenter(
            router: router,
            webService: webService,
            coreDataService: coreDataService,
            product: product,
            image: image
        )
        let view = ProductViewController(presenter: presenter)
        presenter.view = view
        return view
    }
    
    func createCartModule(router: Routing) -> CartViewController {
        let presenter = CartPresenter(
            router: router,
            webService: webService,
            coreDataService: coreDataService
        )
        let view = CartViewController(presenter: presenter)
        presenter.view = view
        return view
    }
    
    func createAddressModule(router: Routing) -> AddressViewController {
        let presenter = AddressPresenter(router: router, keychainService: keychainService)
        let view = AddressViewController(presenter: presenter)
        presenter.view = view
        return view
    }
    
    func createPaymentMethodModule(router: Routing) -> PaymentMethodViewController {
        let presenter = PaymentMethodPresenter(router: router, keychainService: keychainService)
        let view = PaymentMethodViewController(presenter: presenter)
        presenter.view = view
        return view
    }
    
    func createCheckoutModule(router: Routing) -> CheckoutViewController {
        let presenter = CheckoutPresenter(
            router: router,
            keychainService: keychainService,
            webService: webService,
            coreDataService: coreDataService
        )
        let view = CheckoutViewController(presenter: presenter)
        presenter.view = view
        return view
    }
    
    func createPopupModule(
        router: Routing,
        headerTitle: String,
        message: String,
        subMessage: String?,
        buttonTitle: String,
        buttonAction: (() -> Void)?,
        closeAction: (() -> Void)?,
        image: UIImageView
    ) -> PopupViewController {
        let presenter = PopupPresenter(router: router)
        let view = PopupViewController(
            presenter: presenter,
            headerTitle: headerTitle,
            message: message,
            subMessage: subMessage,
            buttonTitle: buttonTitle,
            buttonAction: buttonAction,
            closeAction: closeAction,
            image: image
        )
        presenter.view = view
        return view
    }
    
    func createTestModule(router: Routing) -> TestViewController {
        let presenter = TestPresenter(router: router)
        let view: TestViewController
        view = UIStoryboard(name: "TestStoryboard", bundle: nil)
            .instantiateViewController(identifier: "TestViewController")
        presenter.view = view
        view.presenter = presenter
        return view
    }

}
