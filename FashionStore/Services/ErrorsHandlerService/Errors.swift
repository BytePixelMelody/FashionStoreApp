//
//  Errors.swift
//  FashionStore
//
//  Created by Vyacheslav on 18.04.2023.
//

import Foundation

class Errors {
    
    public static let handler = Errors()
    
    public enum ErrorType: LocalizedError {
        case paymentFail
        case networkConnectionFail
        case httpError(statusCode: Int)
        case keyChainSaveError(errSecCode: Int)
        case keyChainReadError(errSecCode: Int)
        case keyChainDeleteError(errSecCode: Int)
        case keyChainCastError
        
        var errorDescription: String? {
            switch self {
                
            case .paymentFail:
                return "Payment unsuccessful\n\nPlease check your payment method information"
                
            case .networkConnectionFail:
                return "Please check your Internet connection"
            
            // client connection error
            case .httpError(let statusCode) where (400...499).contains(statusCode):
                return "HTTP error \(statusCode)\n\nPlease try again later"
                
            // server connection error
            case .httpError(let statusCode) where (500...599).contains(statusCode):
                return "HTTP error \(statusCode)\n\nServer is not available, please try again later"
                
            // other http error
            case .httpError(let statusCode):
                return "HTTP error \(statusCode)\n\nPlease try again later"
                
            // keychain save error
            case .keyChainSaveError(let errSecCode):
                return "Can not save data to keychain, error \(errSecCode)"
                
            // keychain read error
            case .keyChainReadError(let errSecCode):
                return "Can not read data from keychain, error \(errSecCode)"

            // keychain delete error
            case .keyChainDeleteError(let errSecCode):
                return "Can not delete data from keychain, error \(errSecCode)"

           // read cast error
            case .keyChainCastError:
                return "Can not convert keychain object to data"

            }
        }
    }
    
    private var router: RouterProtocol?
    
    public func setRouter(router: RouterProtocol?) {
        self.router = router
    }
    
    public func checkError(_ checkingError: Error) {
        guard let router else { return }
        
        switch checkingError {
        case Errors.ErrorType.paymentFail:
            let errorAction: () -> Void = {
                router.dismissScreen()
                router.showPaymentMethodScreen()
            }
            router.showErrorMessageScreen(errorLabelText: checkingError.localizedDescription,
                                          errorAction: errorAction,
                                          errorButtonTitle: "To payment method")
        default:
            router.showErrorMessageScreen(errorLabelText: checkingError.localizedDescription,
                                          errorAction: nil,
                                          errorButtonTitle: nil)
        }
    }
    
}
