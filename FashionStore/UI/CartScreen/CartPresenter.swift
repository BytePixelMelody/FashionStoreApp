//
//  CartPresenter.swift
//  FashionStore
//
//  Created by Vyacheslav on 07.03.2023.
//

import Foundation

protocol CartPresenterProtocol {
    func loadCatalog() async throws
    func checkCartInStock() async throws
    func loadCart() async throws
    func showCheckout()
    func closeScreen()
    // TODO: delete this
    func showMockView()
}

class CartPresenter: CartPresenterProtocol {
    weak var view: CartViewProtocol?
    private let router: RouterProtocol
    private let webService: WebServiceProtocol
    private let coreDataService: CoreDataServiceProtocol
    private var cart: Cart?
    private var catalog: Catalog?

    init(
        router: RouterProtocol,
        webService: WebServiceProtocol,
        coreDataService: CoreDataServiceProtocol
    ) {
        self.router = router
        self.webService = webService
        self.coreDataService = coreDataService
    }
    
    func loadCatalog() async throws {
        catalog = try await webService.getData(
            urlString: Settings.catalogUrl,
            cachePolicy: .reloadIgnoringLocalAndRemoteCacheData
        )
    }

    func checkCartInStock() async throws {
        
        guard let catalog else { return }
        
        let itemsInStock = Dictionary(uniqueKeysWithValues: catalog.audiences.flatMap {
            $0.categories.flatMap {
                $0.products.flatMap {
                    $0.colors.flatMap {
                        $0.items.compactMap {
                            ($0.id, $0.inStock)
                        }
                    }
                }
            }
        })
        
        let deletedCartItemsCount = try await coreDataService.syncCartWithAvailableItems(itemsInStock: itemsInStock)
        
        // popup message will be shown
        if deletedCartItemsCount > 0 {
            throw Errors.ErrorType.cartItemsDeleted(count: deletedCartItemsCount)
        }
    }
    
    func loadCart() async throws {
        cart = try await coreDataService.fetchEntireCart()
        
        // run from main thread
        await MainActor.run {
            if let cart, cart.cartItems.isEmpty == false {
                view?.showFullCart()
            } else {
                view?.showEmptyCartWithAnimation()
            }
        }
    }

    func showCheckout() {
        router.showCheckoutScreen()
    }
    
    func closeScreen() {
        router.popScreenToBottom()
    }
    
    // TODO: delete this
    func showMockView() {
        guard let itemId = cart?.cartItems.first?.itemId else { return }
//        gua

//        view?.addMockCellView(
//            productBrandLabelTitle: product.brand,
//            productNameLabelTitle: product.name,
//            productPriceLabelTitle: "$" + product.price.formatted(.number.precision(.fractionLength(0...2))),
//            productId: product.id,
//            imageName: product.images.first
//        )
    }

}
