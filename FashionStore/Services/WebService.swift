//
//  WebService.swift
//  FashionStore
//
//  Created by Vyacheslav on 15.05.2023.
//

import Foundation
import UIKit

protocol WebServiceProtocol: AnyObject {
    func getData<T: Codable>(urlString: String, cachePolicy: URLRequest.CachePolicy) async throws -> T
    func getImage(imageName: String) async throws -> UIImage
}
 
// web service that used to obtain decoded JSON-data by URL string
// extension is used here to set default param to cachePolicy
extension WebServiceProtocol {
    
    // usage example:
    // let catalog: Catalog = try await WebService().getData(urlString: Settings.catalogUrl)
    public func getData<T: Codable>(urlString: String, cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy) async throws -> T {
        // urlString check
        guard let url = URL(string: urlString) else {
            throw Errors.ErrorType.invalidUrlStringError
        }
        
        let urlRequest = URLRequest(url: url, cachePolicy: cachePolicy, timeoutInterval: 5.0)
        
        // try to get data from url
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        // urlResponse typecasting check
        guard let urlResponse = response as? HTTPURLResponse else {
            throw Errors.ErrorType.urlResponseCastError
        }
        
        // status code check
        guard urlResponse.statusCode < 400 else {
            throw Errors.ErrorType.httpError(statusCode: urlResponse.statusCode, urlString: urlString)
        }
        
        // try decode data to T type
        let decodedData = try JSONDecoder().decode(T.self, from: data)
        
        return decodedData
    }
    
}

class WebService: WebServiceProtocol {
    // image loading
    func getImage(imageName: String) async throws -> UIImage {
        
        let urlString = Settings.imagesUrl + imageName
        
        // urlString check
        guard let url = URL(string: urlString) else {
            throw Errors.ErrorType.invalidUrlStringError
        }
        
        let urlRequest = URLRequest(url: url)
        
        // try to get data from url
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        // urlResponse typecasting check
        guard let urlResponse = response as? HTTPURLResponse else {
            throw Errors.ErrorType.urlResponseCastError
        }
        
        // status code check
        guard urlResponse.statusCode < 400 else {
            throw Errors.ErrorType.httpError(statusCode: urlResponse.statusCode, urlString: urlString)
        }
        
        // try decode image to T type
        guard let image = UIImage(data: data) else {
            throw Errors.ErrorType.unsupportedImageFormat
        }
        
        return image
    }
    
}