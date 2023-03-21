//
//  PaymentMethodPresenter.swift
//  FashionStore
//
//  Created by Vyacheslav on 07.03.2023.
//

import Foundation

protocol PaymentMethodPresenterProtocol {
    func closeScreen()
}

class PaymentMethodPresenter: PaymentMethodPresenterProtocol {
    weak var view: PaymentMethodViewProtocol?
    private let router: RouterProtocol

    init(router: RouterProtocol) {
        self.router = router
    }
    
    func closeScreen() {
        router.popScreenToBottom()
    }
}
