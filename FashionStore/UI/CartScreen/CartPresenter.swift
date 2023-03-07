//
//  CartPresenter.swift
//  FashionStore
//
//  Created by Vyacheslav on 07.03.2023.
//

import Foundation

protocol CartPresenterProtocol {
    
}

class CartPresenter: CartPresenterProtocol {
    weak var view: CartViewProtocol?
    private let router: RouterProtocol

    init(router: RouterProtocol) {
        self.router = router
    }
}
