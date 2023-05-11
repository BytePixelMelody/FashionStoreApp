//
//  Errors.swift
//  FashionStore
//
//  Created by Vyacheslav on 18.04.2023.
//

import Foundation
import UIKit

class Errors {
    
    public static let handler = Errors()
    public var router: RouterProtocol?

    public enum ErrorType: LocalizedError {
        case paymentFail
        case networkConnectionFail
        case httpError(statusCode: Int)
        case keyChainSaveError(errSecCode: Int)
        case keyChainReadError(errSecCode: Int)
        case keyChainDeleteError(errSecCode: Int)
        case keyChainCastError
        case emptyTextFieldError
        case notIntegerInputError(errorMessage: String)
        
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

           // read cast error
            case .emptyTextFieldError:
                return "Please fill all required text fields marked with *"

           // read cast error
            case .notIntegerInputError (let errorMessage):
                return errorMessage

            }
        }
    }
        
    public func checkError(_ checkingError: Error) {
        guard let router else { return }
        
        // default popup message values
        let headerTitle = "Sorry"
        let errorMessage = checkingError.localizedDescription
        let errorSubMessage: String? = nil
        var buttonTitle = "OK"
        var buttonAction: (() -> Void)? = nil
        let closeAction: (() -> Void)? = nil
        let image = UIImageView.makeImageView(imageName: ImageName.smileDisappointed, width: 35, height: 35, contentMode: .scaleAspectFit)
        
        // сhanging default values if necessary
        switch checkingError {
        case Errors.ErrorType.paymentFail:
            buttonTitle = "To payment method"
            buttonAction = { router.showPaymentMethodScreen() }
        default:
            break
        }
        
        // show popup screen with error message and actions
        router.showPopupScreen(
            headerTitle: headerTitle,
            message: errorMessage,
            subMessage: errorSubMessage,
            buttonTitle: buttonTitle,
            buttonAction: buttonAction,
            closeAction: closeAction,
            image: image
        )
    }
    
}
