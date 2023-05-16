//
//  CheckoutPresenter.swift
//  FashionStore
//
//  Created by Vyacheslav on 07.03.2023.
//

import Foundation
import UIKit

protocol CheckoutPresenterProtocol {
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
    
    // success purchase popup
    private let successPurchasePopupTitle = "Success"
    private let successPurchasePopupMessageText = "Thank you for your purchase"
    private var successPurchasePopupSubMessageText = "Payment receipt: "
    private let successPurchasePopupButtonTitle = "To store"
    private lazy var goToStoreAction = { [weak self] in
        guard let self else { return }
        self.router.popToRootScreen()
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

    private var cartProducts: [CartProduct] = []

    init(router: RouterProtocol, keychainService: KeychainServiceProtocol) {
        self.router = router
        self.keychainService = keychainService
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
        do{
            switch Int.random(in: 0..<100) {
            case 0..<15:
                throw Errors.ErrorType.networkConnectionFail
            case 15..<20:
                throw Errors.ErrorType.httpError(statusCode: 418)
            case 20..<25:
                throw Errors.ErrorType.httpError(statusCode: 503)
            case 25..<50:
                throw Errors.ErrorType.paymentFail
            default:
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
        } catch {
            Errors.handler.checkError(error)
        }
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
