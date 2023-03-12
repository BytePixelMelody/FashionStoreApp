//
//  Product.swift
//  FashionStore
//
//  Created by Vyacheslav on 12.03.2023.
//

import Foundation

struct Product: Codable {
    var id: UUID
    var brand: String
    var model: String
    var price: Decimal
}
