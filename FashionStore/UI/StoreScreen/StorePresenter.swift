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
    func storeScreenWillAppear()
    func storeScreenWillDisappear()
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

    // storing task to cancel it on willDisappear()
    private var loadCatalogTask: Task<Void, Never>?
    
    init(router: RouterProtocol, webService: WebServiceProtocol, coreDataService: CoreDataServiceProtocol) {
        self.router = router
        self.webService = webService
        self.coreDataService = coreDataService
    }
    
    func showProduct(productId: UUID, image: UIImage?) {
//        guard let product = catalog?.audiences.first?.categories.first?.products.first else {
//            return
//        }
        // search product by id in catalog
        guard let product = catalog?.audiences.flatMap({ $0.categories.flatMap { $0.products } }).first(where: { $0.id == productId }) else {
            return
        }
        
        router.showProductScreen(product: product, image: image)
    }
    
    func showCart() {
        router.showCartScreen()
    }
    
    func storeScreenWillAppear() {
        loadCatalogTask = Task {
            do {
                try Task.checkCancellation()
                catalog = try await webService.getData(
                    urlString: Settings.catalogUrl,
                    cachePolicy: .reloadIgnoringLocalAndRemoteCacheData
                )
            } catch {
                await MainActor.run {
                    Errors.handler.checkError(error)
                }
            }
        }
    }
    
    func storeScreenWillDisappear() {
        loadCatalogTask?.cancel()
    }

    // load image from web
    func loadImage(imageName: String) async throws -> UIImage {
        try await webService.getImage(imageName: imageName)
    }
    
    func showMockView() {
//        view?.addMockCellView(
//            productBrandLabelTitle: <#T##String#>,
//            productNameLabelTitle: <#T##String#>,
//            productPriceLabelTitle: <#T##String#>,
//            productId: <#T##UUID#>,
//            imageName: <#T##String#>
//        )
    }
}
