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
        router.showProductScreen()
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
                
                print(catalog ?? "")
            } catch {
                await MainActor.run {
                    Errors.handler.checkError(error)
                }
            }
        }
    }
    
    private func saveInCoreData(catalog: Catalog) {
        let mainContext = coreDataService.mainContext
        
//        let casualStyle = StyleModel(context: mainContext)
//        casualStyle.id = UUID()
//        casualStyle.name = "Casual"
//
//        let styleFetchRequest = StyleModel.fetchRequest()
//        do {
//            let readStyle = try mainContext.fetch(styleFetchRequest)
//            print(readStyle.first?.name ?? "readStyle.first?.name = nil")
//        } catch {
//            Errors.handler.checkError(error)
//        }
                
        coreDataService.saveMainContext()
    }
    
    func storeScreenWillDisappear() {
        loadCatalogTask?.cancel()
    }

}
