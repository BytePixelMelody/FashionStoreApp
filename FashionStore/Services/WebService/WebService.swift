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
            // urlString check
            guard let url = URL(string: urlString) else {
                throw Errors.ErrorType.invalidUrlStringError
            }
            
            // try to get data from url
            let (data, response) = try await URLSession.shared.data(from: url)
            
            // urlResponse typecasting check
            guard let urlResponse = response as? HTTPURLResponse else {
                throw Errors.ErrorType.urlResponseCastError
            }
            
            // status code check
            guard urlResponse.statusCode < 400 else {
                throw Errors.ErrorType.httpError(statusCode: urlResponse.statusCode)
            }
            
            // try decode data to T type
            let decodedData = try JSONDecoder().decode(T.self, from: data)
            
            return decodedData
            
        } catch let error as NSError where // no Internet connection
                    error.domain == NSURLErrorDomain &&
                    error.code == NSURLErrorNotConnectedToInternet {
            Errors.handler.checkError(Errors.ErrorType.networkConnectionFail)
            return nil
        } catch { // any other error
            Errors.handler.checkError(error)
            return nil
        }
    }
    
}
