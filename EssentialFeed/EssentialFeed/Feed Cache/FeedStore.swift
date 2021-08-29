//
//  FeedStore.swift
//  FeedStore
//
//  Created by Elon on 13/08/2021.
//

import Foundation

public typealias CacheFeed = (feed: [LocalFeedImage], timestamp: Date)

public protocol FeedStore {
    typealias DeleteionResult = Result<Void, Error>
    typealias DeletionCompletion = (DeleteionResult) -> Void
    
    typealias InsertResult = Result<Void, Error>
    typealias InsertionCompletion = (InsertResult)-> Void
    
    typealias RetrievalResult = Result<CacheFeed?, Error>
    typealias RetrievalCompletion = (RetrievalResult) -> Void
    
    func deleteCacheFeed(completion: @escaping DeletionCompletion)
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion:  @escaping InsertionCompletion)
    
    func retrieve(completion:  @escaping RetrievalCompletion)
}
