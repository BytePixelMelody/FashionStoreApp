//
//  CheckoutPresenter.swift
//  FashionStore
//
//  Created by Vyacheslav on 07.03.2023.
//

import Foundation

protocol CheckoutPresenterProtocol {
    func closeScreen()
    func addAddress()
    func addPaymentCard()
    func placeOrder()
    func checkoutIsEmptyCheck()
    func closeCheckoutAndCart()
}

class CheckoutPresenter: CheckoutPresenterProtocol {
    weak var view: CheckoutViewProtocol?
    private let router: RouterProtocol
    private var cartProducts: [CartProduct] = []

    init(router: RouterProtocol) {
        self.router = router
    }
    
    func closeScreen() {
        router.popScreenToBottom()
    }
    
    func addAddress() {
        router.showAddressScreen()
    }
    
    func addPaymentCard() {
        router.showPaymentMethodScreen()
    }
    
    func closeCheckoutAndCart() {
        router.popTwoScreensToBottom()
    }
    
    func placeOrder() {
        //fatalError("Show Address / Payment Method / Success not realised")
    }
    
    func checkoutIsEmptyCheck() {
        if !cartProducts.isEmpty {
            view?.showEmptyCheckoutWithAnimation()
        } else {
            view?.showFullCheckout()
        }
    }
}
