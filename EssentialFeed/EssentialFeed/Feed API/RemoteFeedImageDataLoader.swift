//
//  RemoteFeedImageDataLoader.swift
//  RemoteFeedImageDataLoader
//
//  Created by Elon on 20/08/2021.
//

import Foundation

public class RemoteFeedImageDataLoader: FeedImageDataLoader {
    private let client: HTTPClient
    
    public init(client: HTTPClient) {
        self.client = client
    }
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public typealias Result = FeedImageDataLoader.Result
    
    private class CancellableDataTask: FeedImageDataLoaderTask {
        var clientTask: HTTPClientTask?
        private var completion: ((FeedImageDataLoader.Result) -> Void)?
        
        init(_ completion: @escaping (FeedImageDataLoader.Result) -> Void) {
            self.completion = completion
        }
        
        func complete(with result: FeedImageDataLoader.Result) {
            completion?(result)
        }
        
        func cancel() {
            preventFurtherCompletion()
            clientTask?.cancel()
        }
        
        private func preventFurtherCompletion() {
            completion = nil
        }
    }
    
    public func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> FeedImageDataLoaderTask {
        let task = CancellableDataTask(completion)
        task.clientTask = client.get(from: url) {[weak self] result in
            guard `self` != nil else {return}
            
            task.complete(with: result
                            .mapError{ _ in Error.connectivity }
                            .flatMap{ (data, response) in
                let isValidResponse = response.isOK() && !data.isEmpty
                return isValidResponse ? .success(data) : .failure(Error.invalidData)
            })
        }
        
        return task
    }
}
