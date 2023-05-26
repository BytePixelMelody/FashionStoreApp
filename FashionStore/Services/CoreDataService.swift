//
//  CoreDataService.swift
//  FashionStore
//
//  Created by Vyacheslav on 21.05.2023.
//

import Foundation
import CoreData

protocol CoreDataServiceProtocol {
    func addCartItemToCart(item: Item) async throws
    func checkItemInCart(item: Item) async throws -> Bool
    func fetchEntireCart() async throws -> Cart
    func editCartItemCount(item: Item, newCount: Int) async throws
    func removeCartItemFromCart(item: Item) async throws
}

class CoreDataService: CoreDataServiceProtocol {
    
    // creating of Core Data persistentContainer
    private lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container. This implementation
         creates and returns a container. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "FashionStoreDb")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            do {
                if let error { throw error }
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
            } catch {
                Errors.handler.checkError(error)
            }
        })
        return container
    }()
    
    // Background queue Core Data context. Use with backgroundContext.perform { }
    private lazy var backgroundContext = persistentContainer.newBackgroundContext()
    
    // add item to cart or change count += 1
    func addCartItemToCart(item: Item) async throws {
        // check existing
        let fetchRequest = CartItemModel.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "itemId == %@", item.id.uuidString)
        
        try await backgroundContext.perform {
            let cartItemsModel = try self.backgroundContext.fetch(fetchRequest)
            
            throw Errors.ErrorType.unsupportedImageFormat
            
            if cartItemsModel.isEmpty {
                // create a new entry
                let cartItemModel = CartItemModel(context: self.backgroundContext)
                cartItemModel.id = UUID()
                cartItemModel.count = 1
                cartItemModel.itemId = item.id
                try self.backgroundContext.save()
            } else {
                // increase count
                guard let cartItemModel = cartItemsModel.first else { return }
                cartItemModel.count += 1
                try self.backgroundContext.save()
            }
        }
    }
    
    // check the presence of item in the cart
    func checkItemInCart(item: Item) async throws -> Bool {
        // check existing
        let fetchRequest = CartItemModel.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "itemId == %@", item.id.uuidString)
                
        return try await backgroundContext.perform {
            let cartItemsModel = try self.backgroundContext.fetch(fetchRequest)
            return !cartItemsModel.isEmpty
        }
    }
    
    // return all cart items
    func fetchEntireCart() async throws -> Cart {
        return try await backgroundContext.perform {
            let fetchRequest = CartItemModel.fetchRequest()
            // Core Data result of request SELECT * FROM CartItemModel
            let cartItemsModel = try self.backgroundContext.fetch(fetchRequest)
            
            // struct Result of request SELECT * FROM CartItemModel
            var cartItems: [CartItem] = []
            for cartItemModel in cartItemsModel {
                guard
                    let id = cartItemModel.id,
                    let itemId = cartItemModel.itemId
                else {
                    throw Errors.ErrorType.modelUnwrapError
                }
                // creating item by item
                let cartItem = CartItem(
                    id: id,
                    itemId: itemId,
                    count: Int(cartItemModel.count)
                )
                cartItems.append(cartItem)
            }
            let cart = Cart(cartItems: cartItems)
            return cart
        }
    }
    
    func editCartItemCount(item: Item, newCount: Int) async throws {
        
    }
    
    func removeCartItemFromCart(item: Item) async throws {
        
    }
    
}
