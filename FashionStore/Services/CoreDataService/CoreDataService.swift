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
    
}
