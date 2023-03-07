//
//  ModuleBuilder.swift
//  FashionStore
//
//  Created by Vyacheslav on 07.03.2023.
//

import Foundation

protocol ModuleBuilderProtocol {
    func createStoreModule(router: RouterProtocol) -> StoreViewController
    func createProductModule(router: RouterProtocol) -> ProductViewController
    func createCartModule(router: RouterProtocol) -> CartViewController
    func createAddressModule(router: RouterProtocol) -> AddressViewController
    func createPaymentMethodModule(router: RouterProtocol) -> PaymentMethodViewController
    func createCheckoutModule(router: RouterProtocol) -> CheckoutViewController
    func createTestModule(router: RouterProtocol) -> TestViewController
}
