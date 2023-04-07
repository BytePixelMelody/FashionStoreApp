//
//  CheckoutPresenter.swift
//  FashionStore
//
//  Created by Vyacheslav on 07.03.2023.
//

import Foundation

protocol CheckoutPresenterProtocol {
    func closeScreen()
    func addAddress()
    func addPaymentCard()
    func placeOrder()
    func checkoutIsEmptyCheck()
    func closeCheckoutAndCart()
    func checkoutViewControllerLoaded()
}

class CheckoutPresenter: CheckoutPresenterProtocol {
    weak var view: CheckoutViewProtocol?
    private let router: RouterProtocol
    private var cartProducts: [CartProduct] = []

    init(router: RouterProtocol) {
        self.router = router
    }
    
    func closeScreen() {
        router.popScreenToBottom()
    }
    
    func addAddress() {
        router.showAddressScreen()
    }
    
    func addPaymentCard() {
        router.showPaymentMethodScreen()
    }
    
    func closeCheckoutAndCart() {
        router.popTwoScreensToBottom()
    }
    
    func placeOrder() {
        
    }
    
    func checkoutIsEmptyCheck() {
        if !cartProducts.isEmpty {
            view?.showEmptyCheckoutWithAnimation()
        } else {
            view?.showFullCheckout()
        }
    }
    
    func checkoutViewControllerLoaded() {
        checkChippingAddress()
        checkPaymentMethod()
    }
    
    private func checkChippingAddress() {
        let chippingAddress: ChippingAddress? = ChippingAddress(
            firstName: "Iris",
            lastName: "Watson",
            address: "606-3727 Ulanocorpenter street",
            city: "Roseville",
            state: "NH",
            zipCode: "11523",
            phoneNumber: "(786) 713-8616"
        )
        
        if let chippingAddress {
            let firstAndLastName = "\(chippingAddress.firstName) \(chippingAddress.lastName)"
            let address = chippingAddress.address
            let cityStateZip = "\(chippingAddress.city), \(chippingAddress.state), \(chippingAddress.zipCode)"
            let phone = "\(chippingAddress.phoneNumber)"
            
            view?.showFilledAddressView(firstAndLastName: firstAndLastName,
                                        address: address,
                                        cityStateZip: cityStateZip,
                                        phone: phone)
        } else {
            view?.showAddAddressView()
        }
    }
    
    private func checkPaymentMethod() {
        let paymentMethod: PaymentMethod? = PaymentMethod(
            nameOnCard: "Iris Watson",
            cardNumber: "2365 3654 2365 3698",
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
    
}
