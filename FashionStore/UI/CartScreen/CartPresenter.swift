//
//  CartPresenter.swift
//  FashionStore
//
//  Created by Vyacheslav on 07.03.2023.
//

import Foundation

protocol CartPresenterProtocol {
    func closeScreen()
    func showCheckout()
    func cartIsEmptyCheck()
}

class CartPresenter: CartPresenterProtocol {
    weak var view: CartViewProtocol?
    private let router: RouterProtocol
    private let webService: WebServiceProtocol
    private let coreDataService: CoreDataServiceProtocol
    private var cartProducts: [CartItem] = []

    init(
        router: RouterProtocol,
        webService: WebServiceProtocol,
        coreDataService: CoreDataServiceProtocol
    ) {
        self.router = router
        self.webService = webService
        self.coreDataService = coreDataService
    }
    
    func closeScreen() {
        router.popScreenToBottom()
    }
    
    func showCheckout() {
        router.showCheckoutScreen()
    }
    
    func cartIsEmptyCheck() {
        if !cartProducts.isEmpty {
            view?.showEmptyCartWithAnimation()
        } else {
            view?.showFullCart()
        }
    }
}
