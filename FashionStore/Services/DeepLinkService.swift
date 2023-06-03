//
//  DeepLinkService.swift
//  FashionStore
//
//  Created by Vyacheslav on 21.04.2023.
//

import Foundation

protocol DeepLinkServiceProtocol: AnyObject {
    func fetchProductId(url: URL?) -> String?
}

class DeepLinkService: DeepLinkServiceProtocol {
    // deep link examples:
    // fstore://store/product?id=B07B22E6-0A4C-4A5A-92C2-3B4E17E87822
    // fstore://store/product?id=d61f4df1-1319-4b47-bfa2-1429b789441c
    
    // return productId if found in URL
    func fetchProductId(url: URL?) -> String? {
        guard let url else { return  nil }
        
        let urlComponents = URLComponents(string: url.absoluteString)
        let host = urlComponents?.host
        let path = urlComponents?.path
        
        switch (host, path) {
        case ("store", "/product"):
            guard let id = urlComponents?.queryItems?.first(where: { $0.name == "id" })?.value else {
                return nil
            }
            return id
        default:
            return nil
        }
    }
    
}
