//
//  Cart.swift
//  FashionStore
//
//  Created by Vyacheslav on 12.03.2023.
//

import Foundation

struct Cart: Codable {
    var cartItems: [CartItem]
}

struct CartItem: Codable {
    var id: UUID
    var itemId: UUID
    var count: Int
}
