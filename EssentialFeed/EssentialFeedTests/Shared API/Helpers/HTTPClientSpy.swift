//
//  HTTPClientSpy.swift
//  HTTPClientSpy
//
//  Created by Elon on 20/08/2021.
//

import Foundation
import EssentialFeed

class HTTPClientSpy: HTTPClient {
    private var messages = [(url: URL, completion: (HTTPClient.Result) -> Void)]()
    
    var requestedURLs: [URL] {
        return messages.map { $0.url }
    }
    
    var cancelledImageURLs = [URL]()
    
    private struct TaskSpy: HTTPClientTask {
        var cancelCallback: () -> Void
        
        func cancel() {
            cancelCallback()
        }
    }

    func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        messages.append((url, completion))
        
        return TaskSpy {[weak self] in
            self?.cancelImageDataLoad(from: url)
        }
    }
    
    func cancelImageDataLoad(from url: URL) {
        cancelledImageURLs.append(url)
    }
    
    func complete(with error: Error, at index: Int = 0) {
        messages[index].completion(.failure(error))
    }
    
    func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
        let response = HTTPURLResponse(url: requestedURLs[index], statusCode: code, httpVersion: nil, headerFields: nil)!
        messages[index].completion(.success((data, response)))
    }
}
