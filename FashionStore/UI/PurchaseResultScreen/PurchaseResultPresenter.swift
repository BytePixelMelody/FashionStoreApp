//
//  PurchaseResultPresenter.swift
//  FashionStore
//
//  Created by Vyacheslav on 14.04.2023.
//

import Foundation

protocol PurchaseResultPresenterProtocol {
    func goStoreScreen()
}

class PurchaseResultPresenter: PurchaseResultPresenterProtocol {
    private let router: RouterProtocol
    weak var view: PurchaseResultViewProtocol?
    
    init(router: RouterProtocol) {
        self.router = router
    }

    func goStoreScreen() {
        view?.dismissView()
        router.popToRootScreenToBottom()
    }

}
