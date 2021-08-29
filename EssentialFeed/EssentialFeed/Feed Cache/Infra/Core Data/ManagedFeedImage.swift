//
//  ManagedFeedImage.swift
//  ManagedFeedImage
//
//  Created by Elon on 14/08/2021.
//

import CoreData

@objc(ManagedFeedImage)
class ManagedFeedImage: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var imageDescription: String?
    @NSManaged var location: String?
    @NSManaged var url: URL
    @NSManaged var data: Data?
    @NSManaged var cache: ManagedCache
}

extension ManagedFeedImage {
    
    static func first(with url: URL, in context: NSManagedObjectContext) throws -> ManagedFeedImage? {
        let request = NSFetchRequest<ManagedFeedImage>(entityName: ManagedFeedImage.entity().name!)
        request.predicate = NSPredicate(format: "%K = %@", argumentArray: [#keyPath(ManagedFeedImage.url), url])
        request.fetchLimit = 1
        request.returnsObjectsAsFaults = false
        
        let result = try context.fetch(request)
        
        return result.first
    }
    
    var local: LocalFeedImage {
        LocalFeedImage(id: id,
                       description: imageDescription,
                       location: location,
                       url: url)
    }
}

