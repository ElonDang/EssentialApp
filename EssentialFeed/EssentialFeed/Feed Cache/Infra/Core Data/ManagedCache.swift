//
//  ManagedCache.swift
//  ManagedCache
//
//  Created by Elon on 14/08/2021.
//

import CoreData

@objc(ManagedCache)
class ManagedCache: NSManagedObject {
    @NSManaged var timestamp: Date
    @NSManaged var feed: NSOrderedSet
}

extension ManagedCache {
    static func uniqueInstance(in context: NSManagedObjectContext) throws -> ManagedCache {
        try find(in: context).map(context.delete)
        return ManagedCache(context: context)
    }
    
    static func find(in context: NSManagedObjectContext) throws -> ManagedCache? {
        let fetchRequest: NSFetchRequest<ManagedCache> = NSFetchRequest(entityName: entity().name!)
        fetchRequest.returnsObjectsAsFaults = false
        return try context.fetch(fetchRequest).first
    }
    
    static func images(from feed: [LocalFeedImage], context: NSManagedObjectContext) -> NSOrderedSet {
        NSOrderedSet(array: feed.map {
            let managedImage = ManagedFeedImage(context: context)
            managedImage.id = $0.id
            managedImage.imageDescription = $0.description
            managedImage.location = $0.location
            managedImage.url = $0.url
            
            return managedImage
        })
    }
    
    var localFeed: [LocalFeedImage] {
        feed
            .compactMap {$0 as? ManagedFeedImage}
            .map { $0.local }
    }
}
