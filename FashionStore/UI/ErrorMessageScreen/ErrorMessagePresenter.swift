//
//  ErrorMessagePresenter.swift
//  FashionStore
//
//  Created by Vyacheslav on 17.04.2023.
//

import Foundation

protocol ErrorMessagePresenterProtocol {
    func closeErrorMessageScreen()
}

class ErrorMessagePresenter: ErrorMessagePresenterProtocol {
    private let router: RouterProtocol
    weak var view: ErrorMessageViewProtocol?
    
    init(router: RouterProtocol) {
        self.router = router
    }
    
    func closeErrorMessageScreen() {
        router.dismissScreen()
    }
}
