//
//  CartProduct.swift
//  FashionStore
//
//  Created by Vyacheslav on 12.03.2023.
//

import Foundation

struct CartProduct: Codable {
    var id: UUID
    var product: Product
    var count: Int
}
