//
//  CartPresenter.swift
//  FashionStore
//
//  Created by Vyacheslav on 07.03.2023.
//

import Foundation
import UIKit

protocol CartPresenterProtocol: AnyObject {
    func loadCatalog() async throws
    func checkCartInStock() async throws
    func reloadCart() async throws
    func reloadCollectionView()
    func loadImage(imageName: String) async throws -> UIImage
    func reduceCartItemCount(itemId: UUID, newCount: Int) async throws
    func increaseCartItemCount(itemId: UUID, newCount: Int) async throws
    func showCheckout()
    func closeScreen()
    func getCartItems() -> [CartItem]?
    func findProduct(itemId: UUID) -> Product?
    func findColor(itemId: UUID) -> Color?
    func findCatalogItem(itemId: UUID) -> CatalogItem?
    func findCartItem(itemId: UUID) -> CartItem?
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
        await MainActor.run { [weak self] in
            self?.view?.reloadCollectionViewData()
            self?.setTotalPrice()
        }
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
        catalog = try await webService.getData(urlString: Settings.catalogUrl)
    }
    
    func showCheckout() {
        router.showCheckoutScreen()
    }
    
    func closeScreen() {
        router.popScreenToBottom()
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
    
    // on view will appear
    func reloadCollectionView() {
        // apply data snapshot to collection view
        view?.reloadCollectionViewData()
        setTotalPrice()
    }
    
    // load image from web
    func loadImage(imageName: String) async throws -> UIImage {
        try await webService.getImage(imageName: imageName)
    }
    
    func reduceCartItemCount(itemId: UUID, newCount: Int) async throws {
        if newCount == 0 {
            // delete action with popup confirmation
            await MainActor.run {
                removeCartItemWithWarning(itemId: itemId)
            }
        } else {
            // reduce CartItem count
            try await coreDataService.editCartItemCount(itemId: itemId, newCount: newCount)
            // reload cart
            try await reloadCart()
            await MainActor.run { [weak self] in
                self?.view?.updateCollectionViewItems(updatedItemIds: [itemId])
                self?.setTotalPrice()
            }
        }
    }
    
    func increaseCartItemCount(itemId: UUID, newCount: Int) async throws {
        guard
            let itemIdsInStockCount,
            let cartItemInStockCount = itemIdsInStockCount[itemId]
        else { return }
        
        if newCount <= cartItemInStockCount {
            try await coreDataService.editCartItemCount(itemId: itemId, newCount: newCount)
            try await reloadCart()
            await MainActor.run { [weak self] in
                self?.view?.updateCollectionViewItems(updatedItemIds: [itemId])
                self?.setTotalPrice()
            }
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
        }
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
    
    func getCartItems() -> [CartItem]? {
        cart?.cartItems
    }

    // find product by itemId
    func findProduct(itemId: UUID) -> Product? {
        guard let catalog else { return nil }
        
        let allProducts = catalog.audiences.flatMap { $0.categories.flatMap { $0.products } }
        
        let foundProduct = allProducts.first(where: { $0.colors.contains { $0.items.contains { $0.id == itemId } } })
        
        return foundProduct
    }
    
    // find color by itemId
    func findColor(itemId: UUID) -> Color? {
        guard let catalog else { return nil }

        let allColors = catalog.audiences.flatMap { $0.categories.flatMap { $0.products.flatMap { $0.colors } } }
        
        let foundColor = allColors.first(where: { $0.items.contains { $0.id == itemId } })
        
        return foundColor
    }
    
    // find catalog item by itemId
    func findCatalogItem(itemId: UUID) -> CatalogItem? {
        guard let catalog else { return nil }

        let allItems = catalog.audiences.flatMap { $0.categories.flatMap { $0.products.flatMap { $0.colors.flatMap { $0.items } } } }
        
        let foundItem = allItems.first(where: { $0.id == itemId } )
        
        return foundItem
    }
   
    // find cart item by itemId
    func findCartItem(itemId: UUID) -> CartItem? {
        guard let cart else { return nil }
        
        return cart.cartItems.first(where: { $0.itemId == itemId })
    }
    
    // total cart price
    private func setTotalPrice() {
        let result: Decimal?
        
        // cart is not nil
        if let cartItems = cart?.cartItems  {
            var totalPrice: Decimal = 0.00
            for cartItem in cartItems {
                guard let product = findProduct(itemId: cartItem.itemId) else { break }
                totalPrice += product.price * Decimal(cartItem.count)
            }
            result = totalPrice
        } else {
            result = nil
        }
        view?.setTotalPrice(price: result)
    }
    
}
