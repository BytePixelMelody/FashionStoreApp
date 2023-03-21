//
//  AddressPresenter.swift
//  FashionStore
//
//  Created by Vyacheslav on 07.03.2023.
//

import Foundation

protocol AddressPresenterProtocol {
    func closeScreen()
}

class AddressPresenter: AddressPresenterProtocol {
    weak var view: AddressViewProtocol?
    private let router: RouterProtocol

    init(router: RouterProtocol) {
        self.router = router
    }
    
    func closeScreen() {
        router.popScreenToBottom()
    }
}
