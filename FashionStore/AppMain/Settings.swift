//
//  Settings.swift
//  FashionStore
//
//  Created by Vyacheslav on 03.05.2023.
//

import Foundation

struct Settings {

    // keychain ids
    public static let keychainChippingAddressID = "com.vnazimko.fashion.store.chipping.address"
    public static let keychainPaymentMethodID = "com.vnazimko.fashion.store.payment.method"

    // webserver urls
    public static let fashionStoreURL = "https://bytepixelmelody.github.io/FashionStoreApp/Website/"
    public static var catalogURL: String { fashionStoreURL.appending("catalog.json") }
    public static var imagesURL: String { fashionStoreURL.appending("images/") }

}
