//
//  Settings.swift
//  FashionStore
//
//  Created by Vyacheslav on 03.05.2023.
//

import Foundation

struct Settings {

    // keychain ids
    static let keychainChippingAddressID = "com.vnazimko.fashion.store.chipping.address"
    static let keychainPaymentMethodID = "com.vnazimko.fashion.store.payment.method"

    // webserver urls
    static let fashionStoreURL = "https://bytepixelmelody.github.io/FashionStoreApp/Website/"
    static var catalogURL: String { fashionStoreURL.appending("catalog.json") }
    static var imagesURL: String { fashionStoreURL.appending("images/") }

}
