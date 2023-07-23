//
//  Cart.swift
//  FashionStore
//
//  Created by Vyacheslav on 12.03.2023.
//

import Foundation

struct Cart: Codable, Hashable {
    var cartItems: [CartItem]
}

struct CartItem: Codable, Hashable {
    var id: UUID
    var itemID: UUID
    var count: Int
}
