//
//  Catalog.swift
//  FashionStore
//
//  Created by Vyacheslav on 19.05.2023.
//

import Foundation

// JSON array
struct Catalog: Codable, Hashable {
    var audiences: [Audience]
}

struct Audience: Codable, Hashable {
    var id: UUID
    var name: String // "Women", "Men", "Kids"
    var categories: [Category]
}

struct Category: Codable, Hashable {
    var id: UUID
    var name: String // "Apparel", "Shoes", "Bags", "Accessoires"
    var products: [Product]
}

struct Product: Codable, Hashable {
    var id: UUID
    var name: String // "Dot print corset dress", "Blazer with tuxedo collar" etc
    var brand: String // "Mohani", "Diolo", "Loriani", "Totto", "Jole" etc
    var price: Decimal // 45.00...950.00
    var images: [String] // ["100001", "200001", "300001" etc]
    var material: String // "Cotton", "Wool", "Linum" etc
    var information: String // "Long sleeve jacket with tuxedo collar. Front flap pockets and chest welt pocket. Tonal matching inner lining. Front button closure." etc
    var styles: [Style]
    var colors: [Color]
}

struct Style: Codable, Hashable {
    var id: UUID
    var name: String // "Business", "Smart casual", "Casual" etc
}

struct Color: Codable, Hashable {
    var id: UUID
    var name: String // "black", "pink", "navy" etc
    var hex: String // "#000000", "#FFC0CB", "#000080" ect
    var images: [String] // ["100001", "100002", "100002", "100004" etc]
    var items: [Item]
}

struct Item: Codable, Hashable, Identifiable {
    var id: UUID
    var size: String // "XS", "S", "M", "L", "XL", "XXL"
    var inStock: Int // 1...1000
}
