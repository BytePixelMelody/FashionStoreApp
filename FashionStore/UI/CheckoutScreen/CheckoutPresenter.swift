//
//  CheckoutPresenter.swift
//  FashionStore
//
//  Created by Vyacheslav on 07.03.2023.
//

import Foundation
import UIKit

protocol CheckoutPresenterProtocol: AnyObject {
    func loadCatalog() async throws
    func checkCartInStock() async throws
    func reloadCart() async throws
    func reloadCollectionView()
    func loadImage(imageName: String) async throws -> UIImage
    func reduceCartItemCount(itemId: UUID, newCount: Int) async throws
    func increaseCartItemCount(itemId: UUID, newCount: Int) async throws
    func closeScreen()
    func editAddress()
    func deleteAddress()
    func editPaymentMethod()
    func deletePaymentCard()
    func placeOrder() async throws
    func closeCheckoutAndCart()
    func fillChippingAddressAndPaymentMethod()
    func getCartItems() -> [CartItem]?
    func findProduct(itemId: UUID) -> Product?
    func findColor(itemId: UUID) -> Color?
    func findCatalogItem(itemId: UUID) -> CatalogItem?
    func findCartItem(itemId: UUID) -> CartItem?
}

final class CheckoutPresenter: CheckoutPresenterProtocol {
    weak var view: CheckoutViewProtocol?
    private let router: Routing
    private let keychainService: KeychainServiceProtocol
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

    // success purchase popup
    private let successPurchasePopupTitle = "Success"
    private let successPurchasePopupMessageText = "Thank you for your purchase"
    private var successPurchasePopupSubMessageText = "Payment receipt: "
    private let successPurchasePopupButtonTitle = "To store"
    private lazy var goToStoreAction = { [weak router] in
        guard let router else { return }
        router.popToRootScreen()
    }
    private let successImage = UIImageView.makeImageView(imageName: ImageName.success)
 
    // delete address popup
    private let deleteAddressPopupTitle = "We care"
    private let deleteAddressPopupMessageText = "Do you really want to delete the delivery address?"
    private let deleteAddressPopupButtonTitle = "Delete address"
    private lazy var deleteAddressAction = { [weak self] in
        guard let self else { return }
        do {
            try keychainService.delete(keychainId: Settings.keychainChippingAddressId)
            view?.showAddAddressView()
        } catch {
            Errors.handler.checkError(error)
        }
    }
    private let deleteImage = UIImageView.makeImageView(imageName: ImageName.message)
 
    // delete payment method popup
    private let deletePaymentMethodPopupTitle = "We care"
    private let deletePaymentMethodPopupMessageText = "Do you really want to remove the payment method?"
    private let deletePaymentMethodPopupButtonTitle = "Remove card"
    private lazy var deletePaymentMethodAction = { [weak self] in
        guard let self else { return }
        do {
            try keychainService.delete(keychainId: Settings.keychainPaymentMethodId)
            view?.showAddPaymentMethodView()
        } catch {
            Errors.handler.checkError(error)
        }
    }

    // no chipping address popup
    private let addChippingAddressPopupTitle = "Missing address"
    private let addChippingAddressMessageText = "Please add the shipping address"
    private let addChippingAddressButtonTitle = "Add address"
    private lazy var addChippingAddressAction = { [weak self] in
        guard let self else { return }
        editAddress()
    }
    private let addImage = UIImageView.makeImageView(imageName: ImageName.message)

    // no payment method popup
    private let addPaymentMethodPopupTitle = "Missing payment method"
    private let addPaymentMethodMessageText = "Please add a payment card"
    private let addPaymentMethodButtonTitle = "Add card"
    private lazy var addPaymentMethodAction = { [weak self] in
        guard let self else { return }
        editPaymentMethod()
    }

    private var cartProducts: [CartItem] = []
    
    init(
        router: Routing,
        keychainService: KeychainServiceProtocol,
        webService: WebServiceProtocol,
        coreDataService: CoreDataServiceProtocol
    ) {
        self.router = router
        self.keychainService = keychainService
        self.webService = webService
        self.coreDataService = coreDataService
    }
    
    func loadCatalog() async throws {
        catalog = try await webService.getData(urlString: Settings.catalogUrl)
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
                view?.showFullCheckout()
            } else {
                view?.showEmptyCheckoutWithAnimation()
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
    
    func closeScreen() {
        router.popScreenToBottom()
    }
    
    func editAddress() {
        router.showAddressScreen()
    }
    
    func editPaymentMethod() {
        router.showPaymentMethodScreen()
    }
    
    func closeCheckoutAndCart() {
        router.popTwoScreensToBottom()
    }
    
    // fake order placement
    @MainActor
    func placeOrder() async throws {
        // if no chipping address - we ask to fill it
        guard let _ = getChippingAddress() else {
            showAddAddressPopup()
            return
        }
        
        // if no payment method - we ask to add it
        guard let _ = getPaymentMethod() else {
            showPaymentMethodPopup()
            return
        }

        // all good, we did it
        orderIsSuccessful()
        
        // clean cart
        try await coreDataService.removeAllCartItemsFromCart()
    }
    
    private func showAddAddressPopup() {
        router.showPopupScreen(
            headerTitle: addChippingAddressPopupTitle,
            message: addChippingAddressMessageText,
            subMessage: nil,
            buttonTitle: addChippingAddressButtonTitle,
            buttonAction: addChippingAddressAction,
            closeAction: nil,
            image: addImage
        )
    }
    
    private func showPaymentMethodPopup() {
        router.showPopupScreen(
            headerTitle: addPaymentMethodPopupTitle,
            message: addPaymentMethodMessageText,
            subMessage: nil,
            buttonTitle: addPaymentMethodButtonTitle,
            buttonAction: addPaymentMethodAction,
            closeAction: nil,
            image: addImage
        )
    }
    
    private func orderIsSuccessful() {
        successPurchasePopupSubMessageText = successPurchasePopupSubMessageText + String(Int.random(in: 100_000...999_999))
        router.showPopupScreen(
            headerTitle: successPurchasePopupTitle,
            message: successPurchasePopupMessageText,
            subMessage: successPurchasePopupSubMessageText,
            buttonTitle: successPurchasePopupButtonTitle,
            buttonAction: goToStoreAction,
            closeAction: goToStoreAction,
            image: successImage
        )
    }
    
    func fillChippingAddressAndPaymentMethod() {
        fillChippingAddress()
        fillPaymentMethod()
    }
    
    private func getChippingAddress() -> ChippingAddress? {
        do {
            return try keychainService.read(keychainId: Settings.keychainChippingAddressId)
        } catch {
            Errors.handler.checkError(error)
            return nil
        }
    }
    
    private func fillChippingAddress() {
        if let chippingAddress = getChippingAddress() {
            let firstAndLastName = "\(chippingAddress.firstName) \(chippingAddress.lastName)"
            let address = chippingAddress.address
            let city = chippingAddress.city.isEmpty ? "" : "\(chippingAddress.city), "
            let state = chippingAddress.state.isEmpty ? "" : "\(chippingAddress.state), "
            let cityStateZip = "\(city)\(state)\(chippingAddress.zipCode)"
            let country = chippingAddress.country
            let phone = chippingAddress.phoneNumber
            
            view?.showFilledAddressView(firstAndLastName: firstAndLastName,
                                        address: address,
                                        cityStateZip: cityStateZip,
                                        country: country,
                                        phone: phone)
        } else {
            view?.showAddAddressView()
        }
    }
    
    private func getPaymentMethod() -> PaymentMethod? {
        do {
            return try keychainService.read(keychainId: Settings.keychainPaymentMethodId)
        } catch {
            Errors.handler.checkError(error)
            return nil
        }
    }

    private func fillPaymentMethod() {
        if let paymentMethod = getPaymentMethod() {
            let cardFirstDigit = String(paymentMethod.cardNumber).prefix(1)
            var paymentSystemImageName = ""
            var paymentSystemName = ""
            switch cardFirstDigit {
            case "2":
                paymentSystemImageName = ImageName.mir
                paymentSystemName = "Mir"
            case "3":
                paymentSystemImageName = ImageName.americanExpress
                paymentSystemName = "American Express"
            case "5":
                paymentSystemImageName = ImageName.masterCard
                paymentSystemName = "Master Card"
            case "6":
                paymentSystemImageName = ImageName.unionPay
                paymentSystemName = "Union Pay"
            default:
                paymentSystemImageName = ImageName.visa
                paymentSystemName = "Visa"
            }
            let cardLastDigits = String(paymentMethod.cardNumber.suffix(4)) // last 4 digits
                     
            view?.showFilledPaymentMethodView(
                paymentSystemImageName: paymentSystemImageName,
                paymentSystemName: paymentSystemName,
                cardLastDigits: cardLastDigits
            )
        } else {
            view?.showAddPaymentMethodView()
        }
    }
    
    // delete chipping address info from keychain and from application
    func deleteAddress() {
        router.showPopupScreen(
            headerTitle: deleteAddressPopupTitle,
            message: deleteAddressPopupMessageText,
            subMessage: nil,
            buttonTitle: deleteAddressPopupButtonTitle,
            buttonAction: deleteAddressAction,
            closeAction: nil,
            image: deleteImage
        )
    }
    
    // delete bank card info from keychain and from application
    func deletePaymentCard() {
        router.showPopupScreen(
            headerTitle: deletePaymentMethodPopupTitle,
            message: deletePaymentMethodPopupMessageText,
            subMessage: nil,
            buttonTitle: deletePaymentMethodPopupButtonTitle,
            buttonAction: deletePaymentMethodAction,
            closeAction: nil,
            image: deleteImage
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
