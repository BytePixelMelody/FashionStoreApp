//
//  ProductPresenter.swift
//  FashionStore
//
//  Created by Vyacheslav on 07.03.2023.
//

import Foundation
import UIKit

protocol ProductPresenterProtocol {
    func backScreen()
    func showCart()
    func addProductToCart()
    func screenDidLoad()
}

class ProductPresenter: ProductPresenterProtocol {
    weak var view: ProductViewProtocol?
    private let router: RouterProtocol
    private let webService: WebServiceProtocol
    private let product: Product
    private let image: UIImage?
    
    init(router: RouterProtocol, webService: WebServiceProtocol, product: Product, image: UIImage?) {
        self.router = router
        self.webService = webService
        self.product = product
        self.image = image
    }
    
    func screenDidLoad() {
        view?.fillProduct(
            productBrandLabelTitle: product.brand,
            productNameLabelTitle: product.name,
            productPriceLabelTitle: "$" + product.price.formatted(.number.precision(.fractionLength(0...2))),
            productDescriptionLabelTitle: product.information,
            image: image
        )
    }
    
    func backScreen() {
        router.popScreen()
    }
    
    func showCart() {
        router.showCartScreen()
    }
    
    func addProductToCart() {
        
    }
}
