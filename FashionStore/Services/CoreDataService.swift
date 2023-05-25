//
//  CoreDataService.swift
//  FashionStore
//
//  Created by Vyacheslav on 21.05.2023.
//

import Foundation
import CoreData

protocol CoreDataServiceProtocol {
    var persistentContainer: NSPersistentContainer { get }
    var mainContext: NSManagedObjectContext { get }
    func saveMainContext()
    func addCartItemToCart(item: Item) async
    func fetchCart() -> Cart?
    func editCartItemCount(item: Item, newCount: Int)
    func removeCartItemFromCart(item: Item)
}

class CoreDataService: CoreDataServiceProtocol {
    
    // creating of Core Data persistentContainer
    lazy var persistentContainer: NSPersistentContainer = {
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

    // Main queue Core Data context. Not for long operations(!)
    var mainContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    // Background queue Core Data context. Use with backgroundContext.perform { }
    var backgroundContext: NSManagedObjectContext {
        persistentContainer.newBackgroundContext()
    }
    
    // Core Data check changes and try to save mainContext
    func saveMainContext() {
        if mainContext.hasChanges {
            do {
                try mainContext.save()
            } catch {
                Errors.handler.checkError(error)
            }
        }
    }
    
    // Core Data check changes and try to save backgroundContext
    func saveBackgroundContext() {
        if backgroundContext.hasChanges {
            do {
                try backgroundContext.save()
            } catch {
                Errors.handler.checkError(error)
            }
        }
    }
    
    func addCartItemToCart(item: Item) async {
        // check existing
        let fetchRequest = CartItemModel.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "itemId == %@", item.id.uuidString)
        
        var cartItemsModel: [CartItemModel] = []
        
        await backgroundContext.perform { [weak self] in
            guard let self else { return }
            do {
                cartItemsModel = try backgroundContext.fetch(fetchRequest)
            } catch {
                Errors.handler.checkError(error)
                return
            }
            
            if cartItemsModel.isEmpty {
                let cartItem = CartItemModel(context: backgroundContext)
                cartItem.id = UUID()
                cartItem.itemId = item.id
                cartItem.count = 1
                saveBackgroundContext()
            } else {
                guard let cartItemModel = cartItemsModel.first else { return }
            }
        }
    }
    
    // return all cart items
    func fetchCart() -> Cart? {
        let fetchRequest = CartItemModel.fetchRequest()
        // Core Data result of request SELECT * FROM CartItemModel
        let cartItemsModel: [CartItemModel]
        do {
            cartItemsModel = try mainContext.fetch(fetchRequest)
        } catch {
            Errors.handler.checkError(error)
            return nil
        }
        
        // struct Result of request SELECT * FROM CartItemModel
        var cartItems: [CartItem] = []
        for cartItemModel in cartItemsModel {
            guard
                let id = cartItemModel.id,
                let itemId = cartItemModel.itemId
            else {
                return nil
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
    
    func editCartItemCount(item: Item, newCount: Int) {
        
    }
    
    func removeCartItemFromCart(item: Item) {
        
    }
    
}
