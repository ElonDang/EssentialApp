//
//  FeedImageDataStoreSpy.swift
//  FeedImageDataStoreSpy
//
//  Created by Elon on 20/08/2021.
//

import Foundation
import EssentialFeed

class FeedImageDataStoreSpy: FeedImageDataStore {
    enum Message: Equatable {
        case retrieve(URL)
        case store(data: Data, for: URL)
    }
    
    private var retrievalCompletions = [(FeedImageDataStore.RetrievalResult) -> Void]()
    private var insertionCompletions = [FeedImageDataStore.InsertionCompletion]()

    var messages = [Message]()
        
    func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
        messages.append(.retrieve(url))
        retrievalCompletions.append(completion)
    }
    
    func completeImageDataLoading(with error: Error, at index: Int = 0) {
        retrievalCompletions[index](.failure(error))
    }
    
    func completeImageDataLoading(with data: Data?, at index: Int = 0) {
        retrievalCompletions[index](.success(data))
    }
    
    func insert(_ data: Data, for url: URL, completion: @escaping FeedImageDataStore.InsertionCompletion) {
        messages.append(.store(data: data, for: url))
        insertionCompletions.append(completion)
    }
    
    func completeImageDataInsertion(with error: Error, at index: Int = 0) {
        insertionCompletions[index](.failure(error))
    }
    
    func completeImageDataInsertionSuccessful(at index: Int = 0) {
        insertionCompletions[index](.success(()))
    }
}
