//
//  CartPresenter.swift
//  FashionStore
//
//  Created by Vyacheslav on 07.03.2023.
//

import Foundation
import UIKit

protocol CartPresenterProtocol {
    func loadCatalog() async throws
    func checkCartInStock() async throws
    func reloadCart() async throws
    func loadImage(imageName: String) async throws -> UIImage
    func reduceCartItemCount(itemId: UUID, currentCartItemCount: Int) async throws -> Int?
    func increaseCartItemCount(itemId: UUID, currentCartItemCount: Int) async throws -> Int?
    func showCheckout()
    func closeScreen()
    // TODO: delete this
    func showMockCartItemCellView()
}

class CartPresenter: CartPresenterProtocol {
    weak var view: CartViewProtocol?
    private let router: RouterProtocol
    private let webService: WebServiceProtocol
    private let coreDataService: CoreDataServiceProtocol
    
    private var cart: Cart?
    private var catalog: Catalog?
    private var itemIdsInStockCount: [UUID : Int]?

    // deleting item popup
    private let deleteCartItemPopupTitle = "We care"
    private let deleteCartItemPopupMessageText = "Remove this item from the shopping cart?"
    private let deleteCartItemPopupButtonTitle = "Remove"
    private lazy var deleteCartItemAction = { [weak self] itemId in
        guard let self else { return }
        try await coreDataService.removeCartItemFromCart(itemId: itemId)
        try await reloadCart()
    }
    private let deleteCartItemImage = UIImageView.makeImageView(imageName: ImageName.message)

    // maximum available quantity has been reached popup
    private let maxCartItemCountPopupTitle = "Sorry"
    private let maxCartItemCountPopupMessageText = "The maximum available quantity has been reached"
    private let maxCartItemCountPopupButtonTitle = "OK"
    private let maxCartItemCountImage = UIImageView.makeImageView(imageName: ImageName.dummy)

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

    // remove unavailable CartItems from cart
    func checkCartInStock() async throws {
        
        guard let catalog else { return }
        
        let allItems = catalog.audiences.flatMap { $0.categories.flatMap { $0.products.flatMap { $0.colors.flatMap { $0.items } } } }
        
        itemIdsInStockCount = Dictionary(uniqueKeysWithValues: allItems.compactMap { ($0.id, $0.inStock) })
        
        guard let itemIdsInStockCount else { return }
        
        let deletedCartItemsCount = try await coreDataService.removeUnavailableCartItems(itemIdsInStockCount: itemIdsInStockCount)
        
        // popup message will be shown
        if deletedCartItemsCount > 0 {
            throw Errors.ErrorType.cartItemsDeleted(count: deletedCartItemsCount)
        }
    }
    
    func reloadCart() async throws {
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
    
    // load image from web
    func loadImage(imageName: String) async throws -> UIImage {
        try await webService.getImage(imageName: imageName)
    }
    
    func reduceCartItemCount(itemId: UUID, currentCartItemCount: Int) async throws -> Int? {
        if currentCartItemCount <= 1 {
            // delete action with popup confirmation
            await MainActor.run {
                removeCartItemWithWarning(itemId: itemId)
            }
            return nil
        } else {
            let newCount = currentCartItemCount - 1
            return try await coreDataService.editCartItemCount(itemId: itemId, newCount: newCount)
        }
    }
    
    func increaseCartItemCount(itemId: UUID, currentCartItemCount: Int) async throws -> Int? {
        guard
            let itemIdsInStockCount,
            let cartItemInStockCount = itemIdsInStockCount[itemId]
        else { return nil }
        
        if currentCartItemCount < cartItemInStockCount {
            // increase cartItem count
            let newCount = currentCartItemCount + 1
            return try await coreDataService.editCartItemCount(itemId: itemId, newCount: newCount)
        } else {
            // popup that maximum available quantity has been reached
            await MainActor.run {
                router.showPopupScreen(
                    headerTitle: maxCartItemCountPopupTitle,
                    message: maxCartItemCountPopupMessageText,
                    subMessage: nil,
                    buttonTitle: maxCartItemCountPopupButtonTitle,
                    buttonAction: nil,
                    closeAction: nil,
                    image: maxCartItemCountImage
                )
            }
            return currentCartItemCount
        }
    }
 
    func showCheckout() {
        router.showCheckoutScreen()
    }
    
    func closeScreen() {
        router.popScreenToBottom()
    }
    
    // TODO: delete this
    func showMockCartItemCellView() {
        guard let cartItem = cart?.cartItems.first else { return }
        let itemId = cartItem.itemId
        guard let catalog else { return }
        guard let product = findProduct(catalog: catalog, itemId: itemId) else { return }
        guard let color = findColor(catalog: catalog, itemId: itemId) else { return }
        guard let item = findItem(catalog: catalog, itemId: itemId) else { return }
        let imageName = color.images.first
        let itemBrand = product.brand
        let productName = product.name
        let colorName = color.name
        let size = item.size
        let itemNameColorSize = "\(productName), \(colorName), \(size)"
        let count = cartItem.count
        let itemPrice = product.price
                        
        view?.addMockCartItemCellView(
            imageName: imageName,
            itemBrand: itemBrand,
            itemNameColorSize: itemNameColorSize,
            itemId: itemId,
            count: count,
            itemPrice: itemPrice
        )
    }
    
    // popup when trying to remove item from cart
    private func removeCartItemWithWarning(itemId: UUID) {
        // transform    (UUID) async throws -> Void    to    () -> Void
        let buttonAction: () -> Void = { [weak self] in
            Task { [weak self] in
                do {
                    try await self?.deleteCartItemAction(itemId)
                } catch {
                    Errors.handler.checkError(error)
                }
            }
        }
        // show popup
        router.showPopupScreen(
            headerTitle: deleteCartItemPopupTitle,
            message: deleteCartItemPopupMessageText,
            subMessage: nil,
            buttonTitle: deleteCartItemPopupButtonTitle,
            buttonAction: buttonAction,
            closeAction: nil,
            image: deleteCartItemImage
        )
    }
    
    // find product by itemId
    private func findProduct(catalog: Catalog, itemId: UUID) -> Product? {
        let allProducts = catalog.audiences.flatMap { $0.categories.flatMap { $0.products } }
        
        let foundProduct = allProducts.first(where: { $0.colors.contains { $0.items.contains { $0.id == itemId } } })
        
        return foundProduct
    }
    
    // find color by itemId
    private func findColor(catalog: Catalog, itemId: UUID) -> Color? {
        let allColors = catalog.audiences.flatMap { $0.categories.flatMap { $0.products.flatMap { $0.colors } } }
        
        let foundColor = allColors.first(where: { $0.items.contains { $0.id == itemId } })
        
        return foundColor
    }
    
    // find item by itemId
    private func findItem(catalog: Catalog, itemId: UUID) -> Item? {
        let allItems = catalog.audiences.flatMap { $0.categories.flatMap { $0.products.flatMap { $0.colors.flatMap { $0.items } } } }
        
        let foundItem = allItems.first(where: { $0.id == itemId } )
        
        return foundItem
    }
   
}
