//
//  AddressPresenter.swift
//  FashionStore
//
//  Created by Vyacheslav on 07.03.2023.
//

import Foundation
import UIKit

protocol AddressPresenterProtocol {
    func backScreen(someTextFieldEdited: Bool)
    func addressScreenWillAppear()
    func saveChanges(
        someTextFieldEdited: Bool,
        firstName: String?,
        lastName: String?,
        address: String?,
        city: String?,
        state: String?,
        zipCode: String?,
        country: String?,
        phoneNumber: String?
    )
}

class AddressPresenter: AddressPresenterProtocol {
    weak var view: AddressViewProtocol?
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
        firstName: String?,
        lastName: String?,
        address: String?,
        city: String?,
        state: String?,
        zipCode: String?,
        country: String?,
        phoneNumber: String?
    ) {
        do {
            // check empty fields
            guard
                let firstName,   !firstName.isEmpty,
                let lastName,    !lastName.isEmpty,
                let address,     !address.isEmpty,
                let city,        !city.isEmpty,
                let state,                          // state text field filling is not necessary
                let zipCode,     !zipCode.isEmpty,
                let country,     !country.isEmpty,
                let phoneNumber, !phoneNumber.isEmpty
            else {
                throw Errors.ErrorType.emptyTextFieldError
            }
            
            // checking if fields was edited
            guard someTextFieldEdited == true else {
                // nothing was edited, just closing the screen
                router.popScreen()
                return
            }
            
            // something was edited, saving data...
            let chippingAddress = ChippingAddress(
                firstName: firstName,
                lastName: lastName,
                address: address,
                city: city,
                state: state,
                zipCode: zipCode,
                country: country,
                phoneNumber: phoneNumber
            )
            
            try keychainService.add(keychainId: Settings.keychainChippingAddressId, value: chippingAddress)
            router.popScreen()
        } catch {
            // if save error - show error and stay on screen
            Errors.handler.checkError(error)
        }
    }
    
    func addressScreenWillAppear() {
        checkAddress()
    }
    
    private func checkAddress() {
        var chippingAddress: ChippingAddress? = nil
        chippingAddress = try? keychainService.read(keychainId: Settings.keychainChippingAddressId)

        if let chippingAddress { 
            view?.showSaveAddressButton()
            // fill text fields address data
            view?.fillAddress(
                firstName: chippingAddress.firstName,
                lastName: chippingAddress.lastName,
                address: chippingAddress.address,
                city: chippingAddress.city,
                state: chippingAddress.state,
                zipCode: chippingAddress.zipCode,
                country: chippingAddress.country,
                phoneNumber: chippingAddress.phoneNumber
            )
        } else {
            view?.showAddAddressButton()
        }
    }
}
