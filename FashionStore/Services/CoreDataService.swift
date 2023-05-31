//
//  CoreDataService.swift
//  FashionStore
//
//  Created by Vyacheslav on 21.05.2023.
//

import Foundation
import CoreData

protocol CoreDataServiceProtocol {
    func addCartItemToCart(itemId: UUID) async throws
    func checkItemInCart(itemId: UUID) async throws -> Bool
    func fetchEntireCart() async throws -> Cart
    func editCartItemCount(itemId: UUID, newCount: Int) async throws -> Int
    func removeCartItemFromCart(itemId: UUID) async throws
    func removeUnavailableCartItems(itemIdsInStockCount: [UUID : Int]) async throws -> Int
}

actor CoreDataService: CoreDataServiceProtocol {
    
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
    func addCartItemToCart(itemId: UUID) async throws {
        // check existing
        let fetchRequest = CartItemModel.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "itemId == %@", itemId.uuidString)
        
        try await backgroundContext.perform {
            let cartItemsModel = try self.backgroundContext.fetch(fetchRequest)
                        
            if cartItemsModel.isEmpty {
                // create a new entry
                let cartItemModel = CartItemModel(context: self.backgroundContext)
                cartItemModel.id = UUID()
                cartItemModel.count = 1
                cartItemModel.itemId = itemId
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
    func checkItemInCart(itemId: UUID) async throws -> Bool {
        // check existing
        let fetchRequest = CartItemModel.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "itemId == %@", itemId.uuidString)
                
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
    
    // edit CartItem count
    func editCartItemCount(itemId: UUID, newCount: Int) async throws -> Int {
        let fetchRequest = CartItemModel.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "itemId == %@", itemId.uuidString)
        // run on background
        try await backgroundContext.perform {
            // first item by itemId
            guard let cartItemModel = try self.backgroundContext.fetch(fetchRequest).first else {
                throw Errors.ErrorType.modelUnwrapError
            }
            // edit count
            cartItemModel.count = Int64(newCount)
            try self.backgroundContext.save()
        }
        return newCount
    }
    
    // remove CartItem from cart
    func removeCartItemFromCart(itemId: UUID) async throws {
        let fetchRequest = CartItemModel.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "itemId == %@", itemId.uuidString)
        fetchRequest.includesPropertyValues = false
        
        // run on background
        try await backgroundContext.perform {
            // all items by itemId
            let cartItemsModel = try self.backgroundContext.fetch(fetchRequest)
            // delete
            for cartItemModel in cartItemsModel {
                self.backgroundContext.delete(cartItemModel)
            }
            // save
            try self.backgroundContext.save()
        }
    }
    
    // delete cartItems that are not in stock in necessary count
    func removeUnavailableCartItems(itemIdsInStockCount: [UUID : Int]) async throws -> Int {
        let fetchRequest = CartItemModel.fetchRequest()
        fetchRequest.includesPropertyValues = true
        
        // run on background
        return try await backgroundContext.perform {
            // deleted cart items count
            var deletedCartItemsCount = 0
            
            // all cart items
            let cartItemsModel = try self.backgroundContext.fetch(fetchRequest)
            
            // delete cartItems that are not in stock in necessary count
            for cartItemModel in cartItemsModel {
                
                // is cartItem in stock?
                if let cartItemId = cartItemModel.itemId,
                   itemIdsInStockCount.keys.contains(cartItemId) {
                    
                    // is count not sufficient?
                    if let itemInStockCount = itemIdsInStockCount[cartItemId],
                       cartItemModel.count > itemInStockCount {
                        deletedCartItemsCount += Int(cartItemModel.count) - itemInStockCount
                        cartItemModel.count = Int64(itemInStockCount)
                    }
                    
                // cart item not found in stock, delete it
                } else {
                    // add count of deleted items
                    deletedCartItemsCount += Int(cartItemModel.count)
                    self.backgroundContext.delete(cartItemModel)
                }
            }
            
            // save
            try self.backgroundContext.save()
            
            return deletedCartItemsCount
        }
    }
    
}
