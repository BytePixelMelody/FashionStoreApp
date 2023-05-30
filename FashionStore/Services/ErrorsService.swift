//
//  Errors.swift
//  FashionStore
//
//  Created by Vyacheslav on 18.04.2023.
//

import Foundation
import UIKit
import OSLog

class Errors {
    
    // singletone
    public static let handler = Errors()
    
    // for router injection
    public var router: RouterProtocol?
    
    // logger, use Console to view logs
    private let logger = Logger(subsystem: #file, category: "Errors handler")

    // error types
    public enum ErrorType: LocalizedError {
        case paymentFail
        case networkConnectionFail
        case httpError(statusCode: Int, urlString: String)
        case keyChainSaveError(errSecCode: Int)
        case keyChainReadError(errSecCode: Int)
        case keyChainDeleteError(errSecCode: Int)
        case keyChainCastError
        case emptyTextFieldError
        case notIntegerInputError(errorMessage: String)
        case invalidUrlStringError
        case urlResponseCastError
        case unsupportedImageFormat
        case modelUnwrapError
        case loadImageError(errorMessage: String)
        case cartItemsDeleted(count: Int)
        
        // errors localized descriptions
        var errorDescription: String? {
            switch self {
                
            case .paymentFail:
                return "Payment unsuccessful\n\nPlease check your payment method information"
                
            case .networkConnectionFail:
                return "Please check your Internet connection"
            
            // client connection error
            case .httpError(let statusCode, let urlString) where (400...499).contains(statusCode):
                return "HTTP error \(statusCode) for URL \(urlString)"
                
            // server connection error
            case .httpError(let statusCode, _) where (500...599).contains(statusCode):
                return "HTTP error \(statusCode)\n\nServer is not available, please try again later"
                
            // other http error
            case .httpError(let statusCode, let urlString):
                return "HTTP error \(statusCode) for URL \(urlString)\n\nPlease try again later"
                
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

           // text field is empty error
            case .emptyTextFieldError:
                return "Please fill all required text fields marked with *"

           // text is not integer
            case .notIntegerInputError (let errorMessage):
                return "Not Integer input error: " + errorMessage

           // invalid URL string error
            case .invalidUrlStringError:
                return "URL string is invalid"
                
            case .urlResponseCastError:
                return "URLResponse casting to HTTPURLResponse finished with error"

            case .unsupportedImageFormat:
                return "Loaded image has unsupported format for using in UIImage"

            case .modelUnwrapError:
                return "Model type unwrapping finished with error"

            case .loadImageError(let errorMessage):
                return "Load image error: " + errorMessage

            case .cartItemsDeleted(let count):
                return "\(count) items are currently unavailable and have been removed from the cart"

            }
        }
    }
        
    // handling errors
    public func checkError(_ checkingError: Error) {
        guard let router else { return }
        
        // default popup message values
        let headerTitle = "Sorry"
        var errorMessage = checkingError.localizedDescription
        let errorSubMessage: String? = nil
        var buttonTitle = "OK"
        var buttonAction: (() -> Void)? = nil
        let closeAction: (() -> Void)? = nil
        let image = UIImageView.makeImageView(imageName: ImageName.smileDisappointed, width: 35, height: 35, contentMode: .scaleAspectFit)
        
        switch checkingError {
        // сhanging popup values
        case Errors.ErrorType.paymentFail:
            buttonTitle = "To payment method"
            buttonAction = { router.showPaymentMethodScreen() }
        case let error as NSError where
            error.domain == NSURLErrorDomain &&
            error.code == NSURLErrorNotConnectedToInternet:
            errorMessage = Errors.ErrorType.networkConnectionFail.localizedDescription
        // no error popup, log and return
        case is DecodingError, Errors.ErrorType.keyChainReadError, Errors.ErrorType.urlResponseCastError:
            logger.error("\(checkingError.localizedDescription, privacy: .public)")
            return
        // Task was cancelled, no error popup, log and return
        case is CancellationError:
            logger.error("Task was cancelled. \(checkingError.localizedDescription, privacy: .public)")
            return
        // no Internet connection error
        case ErrorType.unsupportedImageFormat:
            logger.error("\(checkingError.localizedDescription, privacy: .public)")
            return
        // log 404 errors
        case ErrorType.httpError(let statusCode, _) where (400...499).contains(statusCode):
            logger.error("\(checkingError.localizedDescription, privacy: .public)")
            return
        // log model unwrapping errors
        case ErrorType.modelUnwrapError:
            logger.error("\(checkingError.localizedDescription, privacy: .public)")
            return
        case ErrorType.loadImageError(_):
            logger.error("\(checkingError.localizedDescription, privacy: .public)")
            return
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
        
        // log error
        logger.error("\(checkingError.localizedDescription, privacy: .public)")
    }
    
}
