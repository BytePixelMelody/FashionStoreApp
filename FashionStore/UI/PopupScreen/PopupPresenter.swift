//
//  PopupPresenter.swift
//  FashionStore
//
//  Created by Vyacheslav on 14.04.2023.
//

import Foundation

protocol PopupPresenterProtocol: AnyObject {
    func closePopupScreen()
}

final class PopupPresenter: PopupPresenterProtocol {
    private let router: RouterProtocol
    weak var view: PopupViewProtocol?
    
    init(router: RouterProtocol) {
        self.router = router
    }

    func closePopupScreen() {
        router.dismissScreen()
    }

}
