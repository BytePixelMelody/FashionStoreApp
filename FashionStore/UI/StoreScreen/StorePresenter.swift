//
//  StorePresenter.swift
//  FashionStore
//
//  Created by Vyacheslav on 07.03.2023.
//

import Foundation
import UIKit

protocol StorePresenterProtocol: AnyObject {
    func showProduct(productID: UUID, image: UIImage?)
    func showCart()
    func loadCatalog() async throws
    func loadImage(imageName: String) async throws -> UIImage
    func getProducts() -> [Product]?
}

final class StorePresenter: StorePresenterProtocol {
    weak var view: StoreViewProtocol?
    private let router: Routing
    private let webService: WebServiceProtocol
    private let coreDataService: CoreDataServiceProtocol // load catalog to Core Data
    private var catalog: Catalog?

    init(router: Routing, webService: WebServiceProtocol, coreDataService: CoreDataServiceProtocol) {
        self.router = router
        self.webService = webService
        self.coreDataService = coreDataService
    }

    func showProduct(productID: UUID, image: UIImage?) {
        // search product by id in catalog
        guard let product = catalog?.audiences.flatMap({ $0.categories.flatMap { $0.products } }).first(where: { $0.id == productID }) else {
            return
        }

        router.showProductScreen(product: product, image: image)
    }

    func showCart() {
        router.showCartScreen()
    }

    func loadCatalog() async throws {
        catalog = try await webService.getData(urlString: Settings.catalogURL)
    }

    // load image from web
    func loadImage(imageName: String) async throws -> UIImage {
        try await webService.getImage(imageName: imageName)
    }

    func getProducts() -> [Product]? {
        return catalog?.audiences.flatMap { $0.categories.flatMap { $0.products } }
    }

}
