//
//  TestPresenter.swift
//  FashionStore
//
//  Created by Vyacheslav on 07.03.2023.
//

import Foundation

protocol TestPresenterProtocol: AnyObject {
    
}

class TestPresenter: TestPresenterProtocol {
    weak var view: TestViewProtocol?
    private let router: RouterProtocol

    init(router: RouterProtocol) {
        self.router = router
    }
}
