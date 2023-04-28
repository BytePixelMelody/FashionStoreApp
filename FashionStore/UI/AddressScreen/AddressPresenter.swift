//
//  AddressPresenter.swift
//  FashionStore
//
//  Created by Vyacheslav on 07.03.2023.
//

import Foundation

protocol AddressPresenterProtocol {
    func backScreen()
    func saveChanges()
}

class AddressPresenter: AddressPresenterProtocol {
    weak var view: AddressViewProtocol?
    private let router: RouterProtocol

    init(router: RouterProtocol) {
        self.router = router
    }
    
    func backScreen() {
        router.popScreen()
    }
    
    func saveChanges() {
        router.popScreen()
    }
}
