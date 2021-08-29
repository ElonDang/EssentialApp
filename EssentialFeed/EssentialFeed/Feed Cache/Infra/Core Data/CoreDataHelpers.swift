//
//  CoreDataHelpers.swift
//  CoreDataHelpers
//
//  Created by Elon on 14/08/2021.
//

import CoreData

extension NSPersistentContainer {
    
    static func load(modelName name: String, storeURL: URL, model: NSManagedObjectModel) throws -> NSPersistentContainer {
        let container = NSPersistentContainer(name: name, managedObjectModel: model)
        
        var loadError: Swift.Error?
        container.persistentStoreDescriptions = [NSPersistentStoreDescription(url: storeURL)]
        container.loadPersistentStores { loadError = $1 }
        
        try loadError.map { throw $0 }
        
        return container
    }
    
}

extension NSManagedObjectModel {
    
    static func create(from bundle: Bundle, name: String) -> NSManagedObjectModel? {
        bundle.url(forResource: name, withExtension: "momd")
            .flatMap { NSManagedObjectModel(contentsOf: $0) }
    }
    
}
