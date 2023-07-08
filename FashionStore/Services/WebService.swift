//
//  WebService.swift
//  FashionStore
//
//  Created by Vyacheslav on 15.05.2023.
//

import Foundation
import UIKit

protocol WebServiceProtocol: AnyObject {
    init(cacheService: CacheServiceProtocol)
    func getData<T: Codable>(urlString: String) async throws -> T
    func getImage(imageName: String) async throws -> UIImage
}

final class WebService: WebServiceProtocol {
    
    private let cacheService: CacheServiceProtocol
    
    init(cacheService: CacheServiceProtocol) {
        self.cacheService = cacheService
    }
    
    // usage example:
    // let catalog: Catalog = try await WebService().getData(urlString: Settings.catalogUrl)
    public func getData<T: Codable>(urlString: String) async throws -> T {
        // urlString check
        guard let url = URL(string: urlString) else {
            throw Errors.ErrorType.invalidUrlStringError
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"

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
    
    // image loading
    func getImage(imageName: String) async throws -> UIImage {
        
        if let image = await cacheService.loadCachedImage(imageName: imageName) {
            return image
        }
        
        let urlString = Settings.imagesUrl + imageName
        
        // urlString check
        guard let url = URL(string: urlString) else {
            throw Errors.ErrorType.invalidUrlStringError
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        
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
        
        // cache image in background
        Task.detached(priority: .background) { [weak self] in
            guard let self else { return }
            await cacheService.cacheImage(imageName: imageName, image: image)
        }
        
        return image
    }
    
}
