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
    func addProductToCart()
}

class ProductPresenter: ProductPresenterProtocol {
    weak var view: ProductViewProtocol?
    private let router: RouterProtocol
    private let webService: WebServiceProtocol
    
    init(router: RouterProtocol, webService: WebServiceProtocol) {
        self.router = router
        self.webService = webService
    }
    
    func backScreen() {
        router.popScreen()
    }
    
    func showCart() {
        router.showCartScreen()
    }
    
    func addProductToCart() {
        
    }
}
