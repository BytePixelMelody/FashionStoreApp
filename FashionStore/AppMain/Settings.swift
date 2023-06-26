//
//  Settings.swift
//  FashionStore
//
//  Created by Vyacheslav on 03.05.2023.
//

import Foundation

struct Settings {
    
    // keychain ids
    public static let keychainChippingAddressId = "com.vnazimko.fashion.store.chipping.address"
    public static let keychainPaymentMethodId = "com.vnazimko.fashion.store.payment.method"
    
    // webserver urls
    public static let fashionStoreUrl = "https://bytepixelmelody.github.io/FashionStoreApp/Website/"
    public static var catalogUrl: String { fashionStoreUrl.appending("catalog.json") }
    public static var imagesUrl: String { fashionStoreUrl.appending("images/") }
    
}
