//
//  LocalFeedImageDataLoader.swift
//  LocalFeedImageDataLoader
//
//  Created by Elon on 20/08/2021.
//

import Foundation

public class LocalFeedImageDataLoader {
    private let store: FeedImageDataStore
    
    public init(store: FeedImageDataStore) {
        self.store = store
    }
}
 
extension LocalFeedImageDataLoader: FeedImageDataLoader {
    public enum LoadError: Swift.Error {
        case failed
        case notFound
    }
    
    public typealias LoadResult = FeedImageDataLoader.Result
    
    private class CancellableTask: FeedImageDataLoaderTask {
        private var completion: ((LoadResult) -> Void)?
        
        init(_ completion: @escaping (LoadResult) -> Void) {
            self.completion = completion
        }
        
        func completeWith(_ result: LoadResult) {
            completion?(result)
        }
        
        func cancel() {
            preventFurtherCompletion()
        }
        
        private func preventFurtherCompletion() {
            completion = nil
        }
    }
    
    public func loadImageData(from url: URL, completion: @escaping (LoadResult) -> Void) -> FeedImageDataLoaderTask {
        let task = CancellableTask(completion)
        store.retrieve(dataForURL: url) {[weak self] result in
            guard self != nil else {return}
            task.completeWith(result
                                .mapError {_ in LoadError.failed }
                                .flatMap { data in data.map { .success($0) } ?? .failure(LoadError.notFound) })
        }
        
        return task
    }
}

extension LocalFeedImageDataLoader: FeedImageDataCache {
    public enum SaveError: Swift.Error {
        case failed
    }

    public typealias SaveResult = FeedImageDataCache.Result
    
    public func save(_ data: Data, for url: URL, completion: @escaping (SaveResult) -> Void) {
        store.insert(data, for: url) {[weak self] result in
            guard self != nil else {return}
            
            completion(result.mapError {_ in SaveError.failed } )
        }
    }
    
}
