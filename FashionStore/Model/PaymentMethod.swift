//
//  PaymentMethod.swift
//  FashionStore
//
//  Created by Vyacheslav on 07.04.2023.
//

import Foundation

struct PaymentMethod: Codable {
    var nameOnCard: String
    var cardNumber: String
    var expMonth: Int
    var expYear: Int
    var cvv: Int
}
