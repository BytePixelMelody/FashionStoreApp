//
//  ProductPresenter.swift
//  FashionStore
//
//  Created by Vyacheslav on 07.03.2023.
//

import Foundation

protocol ProductPresenterProtocol {
    func backScreen()
    func showCart()
}

class ProductPresenter: ProductPresenterProtocol {
    weak var view: ProductViewProtocol?
    private let router: RouterProtocol
    
    init(router: RouterProtocol) {
        self.router = router
    }
    
    func backScreen() {
        router.popScreen()
    }
    
    func showCart() {
        router.showCartScreen()
    }
}
