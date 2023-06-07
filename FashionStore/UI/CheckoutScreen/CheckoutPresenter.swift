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
    func loadImage(imageName: String) async throws -> UIImage
    func reduceCartItemCount(itemId: UUID, newCount: Int) async throws
    func increaseCartItemCount(itemId: UUID, newCount: Int) async throws
    func closeScreen()
    func editAddress()
    func deleteAddress()
    func editPaymentCard()
    func deletePaymentCard()
    func placeOrder()
    func closeCheckoutAndCart()
    func checkoutScreenWillAppear()
}

class CheckoutPresenter: CheckoutPresenterProtocol {
    weak var view: CheckoutViewProtocol?
    private let router: RouterProtocol
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

    private var cartProducts: [CartItem] = []
    
    init(
        router: RouterProtocol,
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
            // TODO: call view?.reloadDataSource
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
            // TODO: call view?.reloadDataSource
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
    
    func editPaymentCard() {
        router.showPaymentMethodScreen()
    }
    
    func closeCheckoutAndCart() {
        router.popTwoScreensToBottom()
    }
    
    // fake order placement
    func placeOrder() {
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
    
    func checkoutScreenWillAppear() {
        checkChippingAddress()
        checkPaymentMethod()
        checkCart()
    }
    
    private func checkChippingAddress() {
        var chippingAddress: ChippingAddress? = nil
        do {
            chippingAddress = try keychainService.read(keychainId: Settings.keychainChippingAddressId)
        } catch {
            Errors.handler.checkError(error)
        }
        
        if let chippingAddress {
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

    private func checkPaymentMethod() {
        var paymentMethod: PaymentMethod? = nil
        do {
            paymentMethod = try keychainService.read(keychainId: Settings.keychainPaymentMethodId)
        } catch {
            Errors.handler.checkError(error)
        }
        
        if let paymentMethod {
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
    
    private func checkCart() {
        if !cartProducts.isEmpty {
            view?.showEmptyCheckoutWithAnimation()
        } else {
            view?.showFullCheckout()
        }
    }
    
}
