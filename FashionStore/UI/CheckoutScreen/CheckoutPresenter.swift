//
//  CheckoutPresenter.swift
//  FashionStore
//
//  Created by Vyacheslav on 07.03.2023.
//

import Foundation

protocol CheckoutPresenterProtocol {
    func closeScreen()
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
    
    func closeCheckoutAndCart() {
        router.popTwoScreensToBottom()
    }
    
    func placeOrder() {
        fatalError("Show Address / Payment Method / Success not realised")
    }
    
    func checkoutIsEmptyCheck() {
        if cartProducts.isEmpty {
            view?.showEmptyCheckout()
        } else {
            view?.showFullCheckout()
        }
    }
}
