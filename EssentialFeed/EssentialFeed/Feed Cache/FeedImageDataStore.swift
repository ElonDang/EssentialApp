//
//  FeedImageDataStore.swift
//  FeedImageDataStore
//
//  Created by Elon on 20/08/2021.
//

import Foundation

public protocol FeedImageDataStore {
    typealias RetrievalResult = Result<Data?, Error>
    typealias RetrievalCompletion = (RetrievalResult) -> Void
    func retrieve(dataForURL url: URL, completion: @escaping RetrievalCompletion)
    
    typealias InsertionResult = Result<Void, Error>
    typealias InsertionCompletion = (InsertionResult) -> Void
    func insert(_ data: Data, for url: URL, completion: @escaping InsertionCompletion)
}
