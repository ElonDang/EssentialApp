//
//  FeedLoaderSpy.swift
//  FeedLoaderSpy
//
//  Created by Elon on 16/08/2021.
//

import Foundation
import EssentialFeed
import EssentialFeediOS
import Combine

class FeedLoaderSpy: FeedImageDataLoader {
    
    // MARK: - Feed Loader
    private var feedRequests = [PassthroughSubject<[FeedImage], Error>]()

    var loadFeedCallCount: Int {
        return feedRequests.count
    }
    
    func loadPublisher() -> AnyPublisher<[FeedImage], Error> {
        let publisher = PassthroughSubject<[FeedImage], Error>()
        feedRequests.append(publisher)
        return publisher.eraseToAnyPublisher()
    }
    
    func completeFeedLoading(with feed: [FeedImage] = [], at index: Int = 0){
        feedRequests[index].send(feed)
    }
    
    func completeFeedLoading(with error: NSError, at index: Int = 0){
        feedRequests[index].send(completion: .failure(error))
    }
    
    // MARK: - Image Data Loader
    private(set) var cancelledImageURLs = [URL]()
    private var imageRequests = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()
    
    var loadedImageURLs: [URL] {
        imageRequests.map {$0.url}
    }
    
    private struct TaskSpy: FeedImageDataLoaderTask {
        var cancelCallback: () -> Void
        
        func cancel() {
            cancelCallback()
        }
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        imageRequests.append((url, completion))
        
        return TaskSpy {[weak self] in
            self?.cancelImageDataLoad(from: url)
        }
    }
    
    func cancelImageDataLoad(from url: URL) {
        cancelledImageURLs.append(url)
    }
    
    func completeImageLoading(with imageData: Data = Data(), at index: Int = 0) {
        imageRequests[index].completion(.success(imageData))
    }
    
    func completeImageLoadingWithError(at index: Int = 0) {
        let error = NSError(domain: "test", code: 400, userInfo: nil)
        imageRequests[index].completion(.failure(error))
    }
}
