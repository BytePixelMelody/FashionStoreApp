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
    func didLoadHandler()
    func willDisappearHandler()
}

class ProductPresenter: ProductPresenterProtocol {
    weak var view: ProductViewProtocol?
    private let router: RouterProtocol
    private let webService: WebServiceProtocol
    private let product: Product
    private let image: UIImage?
    
    // storing task to cancel it on willDisappearHandler()
    private var faceImageTask: Task<Void, Never>?
    
    init(router: RouterProtocol, webService: WebServiceProtocol, product: Product, image: UIImage?) {
        self.router = router
        self.webService = webService
        self.product = product
        self.image = image
    }
    
    func didLoadHandler() {
        view?.fillProduct(
            productBrandLabelTitle: product.brand,
            productNameLabelTitle: product.name,
            productPriceLabelTitle: "$" + product.price.formatted(.number.precision(.fractionLength(0...2))),
            productDescriptionLabelTitle: product.information,
            image: image
        )
        
        // if image == nil, than load image
        guard image == nil else { return }
        
        faceImageTask = Task {
            // check task cancellation
            guard
                !Task.isCancelled,
                let imageName = product.images.first
            else {
                return
            }
            
            guard let image = await webService.getImage(imageName: imageName) else { return }
            
            // switching run on main queue by calling func fillFaceImage on @MainActor UIViewController
            await view?.fillFaceImage(image: image)
        }
    }
    
    func willDisappearHandler() {
        faceImageTask?.cancel()
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
