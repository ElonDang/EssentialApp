//
//  CoreDataFeedStore+FeedStore.swift
//  CoreDataFeedStore+FeedStore
//
//  Created by Elon on 20/08/2021.
//

import Foundation

extension CoreDataFeedStore: FeedStore {
    public func deleteCacheFeed(completion: @escaping DeletionCompletion) {
        perform { context in
            completion(Result {
                try ManagedCache.find(in: context).map(context.delete)
            })
        }
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        perform { context in
            completion(Result {
                let managedCache = try ManagedCache.uniqueInstance(in: context)
                managedCache.timestamp = timestamp
                managedCache.feed = ManagedCache.images(from: feed, context: context)
                
                try context.save()
            })
        }
    }
    
    public func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        perform { context in
            completion(Result {
                try ManagedCache.find(in: context).map {
                    CacheFeed($0.localFeed, $0.timestamp)
                }
            })
        }
    }
}
