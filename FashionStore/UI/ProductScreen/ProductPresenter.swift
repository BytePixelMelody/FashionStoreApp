//
//  ProductPresenter.swift
//  FashionStore
//
//  Created by Vyacheslav on 07.03.2023.
//

import Foundation

protocol ProductPresenterProtocol {
    
}

class ProductPresenter: ProductPresenterProtocol {
    weak var view: ProductViewProtocol?
    private let router: RouterProtocol
    
    init(router: RouterProtocol) {
        self.router = router
    }
}
