//
//  DeepLinkService.swift
//  FashionStore
//
//  Created by Vyacheslav on 21.04.2023.
//

import Foundation

struct DeepLinkService {
    
    // fstore://store/product?uid=114098 - full deep link
    static func navigateByUrl(url: URL?, router: RouterProtocol?) {
        guard let router, let url else { return }
        
        // dismiss modal screen if presented
        router.dismissScreen()
        
        let urlComponents = URLComponents(string: url.absoluteString)
        let host = urlComponents?.host
        let path = urlComponents?.path
        
        switch (host, path) {
        case ("store", "/product"):
            // productId
            if let _ = urlComponents?.queryItems?.first(where: { $0.name == "uid" })?.value {
                // TODO: open Product screen by productId
                router.showProductScreenInstantly()
            } else {
                fallthrough // switch to default:
            }
        default:
            router.popToRootScreen()
        }
    }
    
}
