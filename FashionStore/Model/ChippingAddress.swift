//
//  ChippingAddress.swift
//  FashionStore
//
//  Created by Vyacheslav on 07.04.2023.
//

import Foundation

struct ChippingAddress: Codable {
    var firstName: String
    var lastName: String
    var address: String
    var city: String
    var state: String
    var zipCode: String
    var phoneNumber: String
}
