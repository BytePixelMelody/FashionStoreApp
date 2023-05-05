//
//  CheckoutPresenter.swift
//  FashionStore
//
//  Created by Vyacheslav on 07.03.2023.
//

import Foundation

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
    private let keychainService: KeychainService
    
    // popup screen info
    private let popupTitle = "Success"
    private let popupMessageText = "Thank you for your purchase"
    private var popupSubMessageText = "Payment receipt: "
    private let popupButtonTitle = "To store"
    private lazy var goToStoreAction = { [weak self] in
        guard let self else { return }
        self.router.dismissScreen()
        self.router.popToRootScreen()
    }
    
    private var cartProducts: [CartProduct] = []

    init(router: RouterProtocol, keychainService: KeychainService) {
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
                popupSubMessageText = popupSubMessageText + String(Int.random(in: 100_000...999_999))
                router.showPopupScreen(
                    headerTitle: popupTitle,
                    message: popupMessageText,
                    subMessage: popupSubMessageText,
                    buttonTitle: popupButtonTitle,
                    buttonAction: goToStoreAction,
                    closeAction: goToStoreAction
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
        chippingAddress = try? keychainService.read(keychainId: Settings.keychainChippingAddressId)

        if let chippingAddress {
            let firstAndLastName = "\(chippingAddress.firstName) \(chippingAddress.lastName)"
            let address = chippingAddress.address
            let cityStateZip = "\(chippingAddress.city), \(chippingAddress.state), \(chippingAddress.zipCode)"
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
    
    // delete chipping address info from keychain and from application
    func deleteAddress() {
        do {
            try keychainService.delete(keychainId: Settings.keychainChippingAddressId)
            view?.showAddAddressView()
        } catch {
            Errors.handler.checkError(error)
        }
    }
    
    private func checkPaymentMethod() {
        let paymentMethod: PaymentMethod? = PaymentMethod(
            nameOnCard: "Iris Watson",
            cardNumber: "5365 3654 2365 3698",
            expMonth: 3,
            expYear: 25,
            cvv: 342
        )
        
        if let paymentMethod {
            let cardFirstDigit = String(paymentMethod.cardNumber.prefix(1))
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
            let cardLastDigits = String(paymentMethod.cardNumber.suffix(4))
                     
            view?.showFilledPaymentMethodView(
                paymentSystemImageName: paymentSystemImageName,
                paymentSystemName: paymentSystemName,
                cardLastDigits: cardLastDigits
            )
        } else {
            view?.showAddPaymentMethodView()
        }
    }
    
    // delete bank card info from keychain and from application
    func deletePaymentCard() {
        do {
            try keychainService.delete(keychainId: Settings.keychainPaymentMethodId)
            view?.showAddPaymentMethodView()
        } catch {
            Errors.handler.checkError(error)
        }
    }
    
    private func checkCart() {
        if !cartProducts.isEmpty {
            view?.showEmptyCheckoutWithAnimation()
        } else {
            view?.showFullCheckout()
        }
    }
    
}
