//
//  PopupPresenter.swift
//  FashionStore
//
//  Created by Vyacheslav on 14.04.2023.
//

import Foundation

protocol PopupPresenterProtocol {
    func closePopupScreen()
}

class PopupPresenter: PopupPresenterProtocol {
    private let router: RouterProtocol
    weak var view: PopupViewProtocol?
    
    init(router: RouterProtocol) {
        self.router = router
    }

    func closePopupScreen() {
        router.dismissScreen()
    }

}