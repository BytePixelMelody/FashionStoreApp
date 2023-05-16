//
//  WebService.swift
//  FashionStore
//
//  Created by Vyacheslav on 15.05.2023.
//

import Foundation

protocol WebServiceProtocol {
    func getData<T: Codable>(urlString: String) async -> T?
}
 
// web service that used to obtain decoded JSON-data by URL string
class WebService: WebServiceProtocol {
    
    public func getData<T: Codable>(urlString: String) async -> T? {
        do {
            guard let url = URL(string: urlString) else {
                throw Errors.ErrorType.invalidUrlStringError
            }
            
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let urlResponse = response as? HTTPURLResponse else {
                throw Errors.ErrorType.urlResponseCastError
            }
            
            guard urlResponse.statusCode < 400 else {
                throw Errors.ErrorType.httpError(statusCode: urlResponse.statusCode)
            }
            
            let decodedData = try JSONDecoder().decode(T.self, from: data)
            
            return decodedData
            
        } catch let error as NSError where // if no Internet connection - handle that, return nil
                    error.domain == NSURLErrorDomain &&
                    error.code == NSURLErrorNotConnectedToInternet {
            Errors.handler.checkError(Errors.ErrorType.networkConnectionFail)
            return nil
        } catch { // if any other error
            Errors.handler.checkError(error)
            return nil
        }
    }
    
}
