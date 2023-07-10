//
//  TestPresenter.swift
//  FashionStore
//
//  Created by Vyacheslav on 07.03.2023.
//

import Foundation

protocol TestPresenterProtocol: AnyObject {
    
}

final class TestPresenter: TestPresenterProtocol {
    weak var view: TestViewProtocol?
    private let router: Routing

    init(router: Routing) {
        self.router = router
    }
}
