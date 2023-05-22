//
//  StorePresenter.swift
//  FashionStore
//
//  Created by Vyacheslav on 07.03.2023.
//

import Foundation
import CoreData

protocol StorePresenterProtocol {
    func showProduct()
    func showCart()
    func storeWillAppear()
    func storeWillDisappear()
}

class StorePresenter: StorePresenterProtocol {
    weak var view: StoreViewProtocol?
    private let router: RouterProtocol
    private let webService: WebServiceProtocol
    private let coreDataService: CoreDataServiceProtocol
    
    // storing task to cancel it on willDisappear()
    private var loadCatalogTask: Task<(), Never>?
    
    init(router: RouterProtocol, webService: WebServiceProtocol, coreDataService: CoreDataServiceProtocol) {
        self.router = router
        self.webService = webService
        self.coreDataService = coreDataService
    }
    
    func showProduct() {
        router.showProductScreen()
    }
    
    func showCart() {
        router.showCartScreen()
    }
    
    func storeWillAppear() {

        loadCatalogTask = Task {
            do {
                // check, if task was cancelled then it will throw CancellationError
                try Task.checkCancellation()
                
                let catalog: Catalog = try await webService.getData(urlString: Settings.catalogUrl)
                _ = catalog
                
                // another check, before hard work, if task was cancelled then it will throw CancellationError
                try Task.checkCancellation()
                
                print(catalog)
            } catch {
                await MainActor.run {
                    Errors.handler.checkError(error)
                }
            }
        }
        
        //        let color = ColorModel()
        //        color.image
    }
    
    func storeWillDisappear() {
        loadCatalogTask?.cancel()
    }

}
