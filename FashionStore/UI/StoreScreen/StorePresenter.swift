//
//  StorePresenter.swift
//  FashionStore
//
//  Created by Vyacheslav on 07.03.2023.
//

import Foundation
import UIKit

protocol StorePresenterProtocol {
    func showProduct()
    func showCart()
    func storeScreenWillAppear()
    func storeScreenWillDisappear()
}

class StorePresenter: StorePresenterProtocol {
    weak var view: StoreViewProtocol?
    private let router: RouterProtocol
    private let webService: WebServiceProtocol
    private let coreDataService: CoreDataServiceProtocol
    private var catalog: Catalog?

    // storing task to cancel it on willDisappear()
    private var loadCatalogTask: Task<Void, Never>?
    
    init(router: RouterProtocol, webService: WebServiceProtocol, coreDataService: CoreDataServiceProtocol) {
        self.router = router
        self.webService = webService
        self.coreDataService = coreDataService
    }
    
    func showProduct() {
        guard let product = catalog?.audiences.first?.categories.first?.products.first else {
            return
        }
        let image = UIImage(named: ImageName.startBackground)
        
        router.showProductScreen(product: product, image: image)
    }
    
    func showCart() {
        router.showCartScreen()
    }
    
    func storeScreenWillAppear() {        
        loadCatalogTask = Task {
            do {
                // check task cancellation
                if Task.isCancelled { return }
                
                catalog = try await webService.getData(urlString: Settings.catalogUrl)
                
//                print(catalog ?? "")
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

}
