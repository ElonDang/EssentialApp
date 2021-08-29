//
//  FeedStoreSpy.swift
//  FeedStoreSpy
//
//  Created by Elon on 13/08/2021.
//

import Foundation
import EssentialFeed

class FeedStoreSpy: FeedStore {

    private var deletionCompletions = [DeletionCompletion]()
    private var insertionCompletions = [InsertionCompletion]()
    private var retrievalCompletions = [RetrievalCompletion]()

    enum Message: Equatable {
        case deleteCachedFeed
        case insert(feed: [LocalFeedImage], timestamp: Date)
        case retrieval
    }
    
    var receivedMessages = [Message]()
    
    func deleteCacheFeed(completion: @escaping DeletionCompletion) {
        deletionCompletions.append(completion)
        receivedMessages.append(.deleteCachedFeed)
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        deletionCompletions[index](.failure(error))
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletions[index](.success(()))
    }
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion:  @escaping InsertionCompletion) {
        receivedMessages.append(.insert(feed: feed, timestamp: timestamp))
        insertionCompletions.append(completion)
    }
    
    func completeInsertion(with error: Error, at index: Int = 0) {
        insertionCompletions[index](.failure(error))
    }
    
    func completeInsertionSuccessfully(at index: Int = 0) {
        insertionCompletions[index](.success(()))
    }
    
    func retrieve(completion: @escaping RetrievalCompletion) {
        receivedMessages.append(.retrieval)
        retrievalCompletions.append(completion)
    }
    
    func completeRetrieval(with error: Error, at index: Int = 0) {
        retrievalCompletions[index](.failure(error))
    }
    
    func completeRetrievalSuccessfulWithEmptyCache(at index: Int = 0) {
        retrievalCompletions[index](.success(nil))
    }
    
    func completeRetrievalSuccessful(with feed: [LocalFeedImage], timestamp: Date, at index: Int = 0) {
        retrievalCompletions[index](.success(CacheFeed(feed, timestamp)))
    }
}
