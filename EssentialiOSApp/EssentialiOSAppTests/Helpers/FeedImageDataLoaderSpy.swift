//
//  FeedImageDataLoaderSpy.swift
//  FeedImageDataLoaderSpy
//
//  Created by Elon on 22/08/2021.
//

import Foundation
import EssentialFeed

class FeedImageDataLoaderSpy: FeedImageDataLoader {
    private struct Task: FeedImageDataLoaderTask {
        private let cancelCallback: () -> Void
        
        init(_ cancelCallback: @escaping () -> Void) {
            self.cancelCallback = cancelCallback
        }
        
        func cancel() {
            cancelCallback()
        }
    }
    
    var cancelledURLs = [URL]()
    private var completions = [(FeedImageDataLoader.Result) -> Void]()
            
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        completions.append(completion)
        
        return Task { [weak self] in
            self?.cancelledURLs.append(url)
        }
    }
    
    func complete(with result: FeedImageDataLoader.Result, at index: Int = 0) {
        completions[index](result)
    }
    
}
