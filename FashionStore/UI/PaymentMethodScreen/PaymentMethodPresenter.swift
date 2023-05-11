//
//  PaymentMethodPresenter.swift
//  FashionStore
//
//  Created by Vyacheslav on 07.03.2023.
//

import Foundation
import UIKit

protocol PaymentMethodPresenterProtocol {
    func backScreen(someTextFieldEdited: Bool)
    func paymentMethodWillAppear()
    func saveChanges(
        someTextFieldEdited: Bool,
        nameOnCard: String?,
        cardNumber: String?,
        expMonth: String?,
        expYear: String?,
        cvv: String?
    )
}

class PaymentMethodPresenter: PaymentMethodPresenterProtocol {
    weak var view: PaymentMethodViewProtocol?
    private let router: RouterProtocol
    private let keychainService: KeychainService

    // popup when back button tapped, but there is any edits
    private let discardChangesPopupTitle = "We care"
    private let discardChangesPopupMessageText = "You have unsaved changes"
    private let discardChangesPopupButtonTitle = "Discard changes"
    private lazy var discardChangesAction = { [weak self] in
        guard let self else { return }
        router.popScreen()
    }
    private let discardChangesImage = UIImageView.makeImageView(imageName: ImageName.message)

    private let notIntegerInputErrorMessage = "Card number, expiration month/year and CVV must contain only digits"
    
    init(router: RouterProtocol, keychainService: KeychainService) {
        self.router = router
        self.keychainService = keychainService
    }

    func backScreen(someTextFieldEdited: Bool) {
        // if there is any edits, than show popup warning screen
        if someTextFieldEdited == true {
            router.showPopupScreen(
                headerTitle: discardChangesPopupTitle,
                message: discardChangesPopupMessageText,
                subMessage: nil,
                buttonTitle: discardChangesPopupButtonTitle,
                buttonAction: discardChangesAction,
                closeAction: nil,
                image: discardChangesImage
            )
        } else {
            // no edits - just pop screen
            router.popScreen()
        }
    }
    
    func saveChanges(
        someTextFieldEdited: Bool,
        nameOnCard: String?,
        cardNumber: String?,
        expMonth: String?,
        expYear: String?,
        cvv: String?
    ) {
        do {
            // checking empty fields
            guard
                let nameOnCard, !nameOnCard.isEmpty,
                let cardNumber, !cardNumber.isEmpty,
                let expMonth,   !expMonth.isEmpty,
                let expYear,    !expYear.isEmpty,
                let cvv,        !cvv.isEmpty
            else {
                throw Errors.ErrorType.emptyTextFieldError
            }
            
           // checking if fields was edited
           guard someTextFieldEdited == true else {
                // nothing was edited, just closing the screen
                router.popScreen()
                return
            }
            
            // something was edited, checking types and saving data
            guard
                // type conversion
                let cardNumberInt = Int(cardNumber.replacingOccurrences(of: " ", with: "")),
                let expMonthInt = Int(expMonth.replacingOccurrences(of: " ", with: "")),
                let expYearInt = Int(expYear.replacingOccurrences(of: " ", with: "").suffix(2)),
                let cvvInt = Int(cvv.replacingOccurrences(of: " ", with: ""))
            else {
                throw Errors.ErrorType.notIntegerInputError(errorMessage: notIntegerInputErrorMessage)
            }
            
            let paymentMethod = PaymentMethod(
                nameOnCard: nameOnCard,
                cardNumber: cardNumberInt,
                expMonth: expMonthInt,
                expYear: expYearInt,
                cvv: cvvInt
            )
            
            // saving to keychain
            try keychainService.add(keychainId: Settings.keychainPaymentMethodId, value: paymentMethod)
            router.popScreen()
        } catch {
            // if save error - show error and stay on screen
            Errors.handler.checkError(error)
        }
    }
    
    func paymentMethodWillAppear() {
        checkPaymentMethod()
    }
    
    private func checkPaymentMethod() {
        var paymentMethod: PaymentMethod? = nil
        paymentMethod = try? keychainService.read(keychainId: Settings.keychainPaymentMethodId)

        if let paymentMethod {
            view?.showSavePaymentMethodButton()
            // fill text fields address data
            view?.fillPaymentMethod(
                nameOnCard: paymentMethod.nameOnCard,
                cardNumber: String(paymentMethod.cardNumber),
                expMonth: String(paymentMethod.expMonth),
                expYear: String(paymentMethod.expYear),
                cvv: String(paymentMethod.cvv)
            )
        } else {
            view?.showAddPaymentMethodButton()
        }
    }

}
