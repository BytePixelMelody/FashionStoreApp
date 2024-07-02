//
//  FashionStoreTests.swift
//  FashionStoreTests
//
//  Created by Vyacheslav on 02.07.2024.
//

import Testing
import UIKit
@testable import FashionStore

class MockView: CartViewProtocol {
    var price: Decimal?

    func showEmptyCartWithAnimation() { }
    func showFullCart() { }
    func setTotalPrice(price: Decimal?) {
        self.price = price
    }
    func reloadCollectionViewData() { }
    func updateCollectionViewItems(updatedItemIDs: [FashionStore.CatalogItem.ID]) { }
}

@MainActor
struct FashionStoreTests {
    let cacheService = CacheService()
    lazy var webService = WebService(cacheService: cacheService)
    let navController = UINavigationController()
    lazy var moduleBuilder = ModuleBuilder(coreDataService: coreDataService, webService: webService)
    lazy var router = Router(navigationController: navController, moduleBuilder: moduleBuilder)
    let coreDataService = CoreDataService()
    lazy var mockView = MockView()
    lazy var cartPresenter: CartPresenterProtocol = {
        let cartPresenter = CartPresenter(router: router, webService: webService, coreDataService: coreDataService)
        cartPresenter.view = mockView
        return cartPresenter
    }()

    @Test(.tags(.cart), arguments: [
        UUID(uuidString: "12f7f81c-348d-4591-a74e-4e11a078b72c") ?? UUID(),
        UUID(uuidString: "1190e35e-bcc9-4d99-bb59-41e7a698c97a") ?? UUID(),
        UUID(uuidString: "86a40c92-6112-4d44-b9bc-032ae7cbb884") ?? UUID()
    ])
    mutating func findProduct(from uuid: UUID) async throws {
        try await cartPresenter.loadCatalog()
        let product = cartPresenter.findProduct(itemID: uuid)
        #expect(product != nil)
    }

    @Test(.tags(.cart))
    mutating func findNoProduct() async throws {
        try await cartPresenter.loadCatalog()
        let product = cartPresenter.findProduct(
            itemID: UUID()
        )
        #expect(product == nil)
    }

    @Test(.tags(.cart))
    mutating func setTotalPrice() async throws {
        try await cartPresenter.reloadCart()
        cartPresenter.reloadCollectionView()
        #expect(mockView.price != nil)
    }
}
