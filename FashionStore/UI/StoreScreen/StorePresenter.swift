//
//  StorePresenter.swift
//  FashionStore
//
//  Created by Vyacheslav on 07.03.2023.
//

import Foundation
import UIKit

protocol StorePresenterProtocol {
    func showProduct(productId: UUID, image: UIImage?)
    func showCart()
    func loadCatalog() async throws
    func loadImage(imageName: String) async throws -> UIImage
    // TODO: delete this
    func showMockView()
}

class StorePresenter: StorePresenterProtocol {
    weak var view: StoreViewProtocol?
    private let router: RouterProtocol
    private let webService: WebServiceProtocol
    private let coreDataService: CoreDataServiceProtocol // load catalog to Core Data
    private var catalog: Catalog?
    
    init(router: RouterProtocol, webService: WebServiceProtocol, coreDataService: CoreDataServiceProtocol) {
        self.router = router
        self.webService = webService
        self.coreDataService = coreDataService
    }
    
    func showProduct(productId: UUID, image: UIImage?) {
        // search product by id in catalog
        guard let product = catalog?.audiences.flatMap({ $0.categories.flatMap { $0.products } }).first(where: { $0.id == productId }) else {
            return
        }
        
        router.showProductScreen(product: product, image: image)
    }
    
    func showCart() {
        router.showCartScreen()
    }
    
    func loadCatalog() async throws {
        catalog = try await webService.getData(
            urlString: Settings.catalogUrl,
            cachePolicy: .reloadIgnoringLocalAndRemoteCacheData
        )
    }
    
    // load image from web
    func loadImage(imageName: String) async throws -> UIImage {
        try await webService.getImage(imageName: imageName)
    }
    
    // TODO: delete this
    func showMockView() {
        guard let product = catalog?.audiences.first?.categories.first?.products.first(where: { $0.id == UUID(uuidString: "c305f1ce-2b34-4a8e-b0b4-34e738eeab7e") ?? UUID() }) else {
            return
        }

        view?.addMockCellView(
            productBrandLabelTitle: product.brand,
            productNameLabelTitle: product.name,
            productPriceLabelTitle: "$" + product.price.formatted(.number.precision(.fractionLength(0...2))),
            productId: product.id,
            imageName: product.images.first
        )
    }
}
