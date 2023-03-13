//
//  CartPresenter.swift
//  FashionStore
//
//  Created by Vyacheslav on 07.03.2023.
//

import Foundation

protocol CartPresenterProtocol {
    func closeScreen()
    func checkout()
    func cartIsEmptyCheck()
}

class CartPresenter: CartPresenterProtocol {
    weak var view: CartViewProtocol?
    private let router: RouterProtocol
    private var cartProducts: [CartProduct] = []

    init(router: RouterProtocol) {
        self.router = router
    }
    
    func closeScreen() {
        router.popScreenToBottom()
    }
    
    func checkout() {
        router.showCheckoutScreen()
    }
    
    func cartIsEmptyCheck() {
        if !cartProducts.isEmpty {
            view?.showEmptyCart()
        } else {
            view?.showFullCart()
        }
    }
}
