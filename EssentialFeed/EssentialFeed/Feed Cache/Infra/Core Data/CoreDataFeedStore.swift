//
//  CoreDataFeedStore.swift
//  CoreDataFeedStore
//
//  Created by Elon on 14/08/2021.
//

import Foundation
import CoreData

public final class CoreDataFeedStore {
    private static let modelName = "FeedStore"
    private static let model = NSManagedObjectModel.create(from: Bundle(for: CoreDataFeedStore.self), name: modelName)
    
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    enum LoadingError: Swift.Error {
        case modelNotFound
        case loadPersistentStoreFailed(Swift.Error)
    }
    
    public init(storeURL: URL) throws {
        guard let model = CoreDataFeedStore.model else {
            throw LoadingError.modelNotFound
        }
        
        container = try NSPersistentContainer.load(modelName: "FeedStore", storeURL: storeURL, model: model)
        context = container.newBackgroundContext()
    }
    
    func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
        let context = self.context
        context.perform {
            action(context)
        }
    }
    
    private func cleanUpReferencesToPersistentStores() {
        context.performAndWait {
            let coordinator = self.container.persistentStoreCoordinator
            try? coordinator.persistentStores.forEach(coordinator.remove)
        }
    }
    
    deinit {
        cleanUpReferencesToPersistentStores()
    }
    
}
