//
//  Catalog.swift
//  FashionStore
//
//  Created by Vyacheslav on 19.05.2023.
//

import Foundation

// JSON array
struct Catalog: Codable {
    var audiences: [Audience]
}

struct Audience: Codable {
    var id: UUID
    var name: String // "Women", "Men", "Kids"
    var categories: [Category]
}

struct Category: Codable {
    var id: UUID
    var name: String // "Apparel", "Shoes", "Bags", "Accessoires"
    var models: [Model]
}

struct Model: Codable {
    var id: UUID
    var name: String // "Jacket with tuxedo collar", "Dot print corset dress", "Blazer with tuxedo collar"
    var brand: String // "MOHAN", "Jodio", "Loriani"
    var price: Decimal // 45.00, 90.00 ... 250.00
    var images: [String] // ["108903", "789060", "879120"]
    var seasons: [String] // ["Spring", "Autumn"], ["Summer"]
    var styles: [String] // ["Business", "Smart casual"]
    var material: String // "Cotton", "Wool", "Linum"
    var description: String // "Long sleeve jacket with tuxedo collar. Front flap pockets and chest welt pocket. Tonal matching inner lining. Front button closure."
    var colors: [Color]
}

struct Color: Codable {
    var id: UUID
    var name: String // "black", "pink", "navy"
    var hex: String // "#000000", "#FFC0CB", "#000080"
    var images: [String] // ["108903", "108904", "108905", "108906"]
    var products: [Product]
}

struct Product: Codable {
    var id: UUID
    var size: String // "S", "M", "L", "XL"
    var quantityAvailable: Int // 3, 20, 150
}
