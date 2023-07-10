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
    private let router: Routing
    weak var view: PopupViewProtocol?
    
    init(router: Routing) {
        self.router = router
    }

    func closePopupScreen() {
        router.dismissScreen()
    }

}
