//
//  CoreDataFeedStore+FeedImgeDataLoader.swift
//  CoreDataFeedStore+FeedImgeDataLoader
//
//  Created by Elon on 20/08/2021.
//

import Foundation

extension CoreDataFeedStore: FeedImageDataStore {
    
    public func retrieve(dataForURL url: URL, completion: @escaping FeedImageDataStore.RetrievalCompletion) {
        perform { context in
            completion(Result {
                try ManagedFeedImage.first(with: url, in: context)?.data
            })
        }
    }
    
    public func insert(_ data: Data, for url: URL, completion: @escaping FeedImageDataStore.InsertionCompletion) {
        perform { context in
            completion(Result {
                let image = try ManagedFeedImage.first(with: url, in: context)
                image?.data = data
                try context.save()
            })
        }
    }
    
}
 
