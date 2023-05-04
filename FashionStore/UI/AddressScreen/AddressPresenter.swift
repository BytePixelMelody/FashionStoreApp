//
//  AddressPresenter.swift
//  FashionStore
//
//  Created by Vyacheslav on 07.03.2023.
//

import Foundation

protocol AddressPresenterProtocol {
    func backScreen()
    func addressScreenWillAppear()
    func saveChanges(
        firstName: String,
        lastName: String,
        address: String,
        city: String,
        state: String,
        zipCode: String,
        country: String,
        phoneNumber: String
    )
}

class AddressPresenter: AddressPresenterProtocol {
    weak var view: AddressViewProtocol?
    private let router: RouterProtocol
    private let keychainService: KeychainService

    init(router: RouterProtocol, keychainService: KeychainService) {
        self.router = router
        self.keychainService = keychainService
    }
    
    func backScreen() {
        router.popScreen()
    }
    
    func saveChanges(
        firstName: String,
        lastName: String,
        address: String,
        city: String,
        state: String,
        zipCode: String,
        country: String,
        phoneNumber: String
    ) {
        let address = ChippingAddress(
            firstName: firstName,
            lastName: lastName,
            address: address,
            city: city,
            state: state,
            zipCode: zipCode,
            country: country,
            phoneNumber: phoneNumber
        )
        
        do {
            try keychainService.add(keychainId: Settings.keychainChippingAddressId, value: address)
//            try keychainService.delete(keychainId: Settings.keychainChippingAddressId)
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
