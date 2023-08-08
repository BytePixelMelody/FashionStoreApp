//
//  CacheService.swift
//  FashionStore
//
//  Created by Vyacheslav on 25.06.2023.
//

import UIKit

protocol CacheServiceProtocol {
    func cacheImage(imageName: String, image: UIImage) async
    func loadCachedImage(imageName: String) async -> UIImage?
}


// TODO: delete this after test
final actor MockCacheService: CacheServiceProtocol {
    
    func cacheImage(imageName: String, image: UIImage) async {
        
    }
    
    func loadCachedImage(imageName: String) async -> UIImage? {
        nil
    }
    
}

final actor CacheService: CacheServiceProtocol {
    
    // async func of actor to cache image
    func cacheImage(imageName: String, image: UIImage) {
        guard let url = getCacheURL()?.appending(path: imageName) else { return }
        guard let data = image.jpegData(compressionQuality: 0.92) else { return }
        do {
            // write file if it is not exist
            if !FileManager.default.fileExists(atPath: url.path()) {
                try data.write(to: url)
            }
        } catch {
            Errors.handler.logError(error)
        }
    }
    
    // async func of actor to retrieve image
    func loadCachedImage(imageName: String) -> UIImage? {
        guard let url = getCacheURL()?.appending(path: imageName) else { return nil }

        do {
            let data = try Data(contentsOf: url)
            return UIImage(data: data)
        } catch {
            return nil
        }
    }
    
    // generate cache url
    private func getCacheURL() -> URL? {
        do {
            var url = try FileManager.default.url(
                for: .cachesDirectory,
                in: .allDomainsMask,
                appropriateFor: nil,
                create: true)
            url.append(path: "ImageCache")
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
            return url
        } catch {
            let error = Errors.ErrorType.invalidURLStringError
            Errors.handler.logError(error)
            return nil
        }
    }
    
}
