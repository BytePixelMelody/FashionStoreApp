//
//  KeychainService.swift
//  FashionStore
//
//  Created by Vyacheslav on 03.05.2023.
//

import Foundation
import Security

class KeychainService {
    
    // add item to keychain
    public func add<T>(keychainId: String, value: T) throws where T: Codable {
        let jsonEncoder = JSONEncoder()
        let data = try jsonEncoder.encode(value)
        
        // creating keychain query for add operation
        let addQuery: [String: Any] = [
            kSecAttrService as String: keychainId, // service + account = id to data access
            kSecValueData as String: data, // encoded data to store in keychain
            kSecClass as String: kSecClassGenericPassword, // type of secure data
            kSecAttrSynchronizable as String: kCFBooleanTrue as Any // store in iCloud
        ]
        
        // add to keychain, result is status code
        var status = SecItemAdd(addQuery as CFDictionary, nil)
        
        // if data is already exist
        if status == errSecDuplicateItem {
            // creating query for update operation
            let updateQuery: [String: Any] = [
                kSecAttrService as String: keychainId, // service + account = id to data access
                kSecClass as String: kSecClassGenericPassword, // type of secure data
                kSecAttrSynchronizable as String: kCFBooleanTrue as Any // store in iCloud
            ]
            // data to update in keychain
            let updateAttributes = [kSecValueData: data] as CFDictionary
            
            // update data in keychain, result is status code
            status = SecItemUpdate(updateQuery as CFDictionary, updateAttributes)
        }
        
        // check errors
        guard status == errSecSuccess else {
            throw Errors.ErrorType.keyChainSaveError(errSecCode: Int(status))
        }
    }
    
    // read item from keychain
    public func read<T>(keychainId: String) throws -> T where T: Codable {
        // creating keychain query for read operation
        let readQuery: [String: Any] = [
            kSecAttrService as String: keychainId, // id to data access
            kSecClass as String: kSecClassGenericPassword, // type of secure data in keychain
            kSecAttrSynchronizable as String: kCFBooleanTrue as Any, // store in iCloud
            kSecReturnData as String: true // return the data flag
        ]
        
        // read keychain object
        var keychainObject: AnyObject?
        
        // read operation status code
        let status = SecItemCopyMatching(readQuery as CFDictionary, &keychainObject)
        
        // check errors
        guard status == errSecSuccess else {
            throw Errors.ErrorType.keyChainReadError(errSecCode: Int(status))
        }
        
        // check cast error
        guard let data = keychainObject as? Data else {
            throw Errors.ErrorType.keyChainCastError
        }
        
        // decoder for data
        let jsonDecoder = JSONDecoder()
        
        // return decoded result of type T
        return try jsonDecoder.decode(T.self, from: data)
    }
    
    // delete item from keychain by keychainId
    public func delete(keychainId: String) throws {
        // creating keychain query for delete operation
        let deleteQuery: [String: Any] = [
            kSecAttrService as String: keychainId, // service + account = id to data access
            kSecClass as String: kSecClassGenericPassword, // type of secure data in keychain
            kSecAttrSynchronizable as String: kCFBooleanTrue as Any // store in iCloud
        ]
        
        // delete operation return status code
        let status = SecItemDelete(deleteQuery as CFDictionary)
        
        guard status == errSecSuccess else {
            throw Errors.ErrorType.keyChainDeleteError(errSecCode: Int(status))
        }
    }
    
}
