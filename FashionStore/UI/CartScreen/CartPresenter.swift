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
    func cartIsEmpty() -> Bool
}

class CartPresenter: CartPresenterProtocol {
    weak var view: CartViewProtocol?
    private let router: RouterProtocol
    private var cartProducts: [CartProduct] = []

    init(router: RouterProtocol) {
        self.router = router
    }
    
    func closeScreen() {
        router.dismissScreen()
    }
    
    func checkout() {
        fatalError("Not realised")
    }
    
    func cartIsEmpty() -> Bool {
        cartProducts.isEmpty
    }
}
