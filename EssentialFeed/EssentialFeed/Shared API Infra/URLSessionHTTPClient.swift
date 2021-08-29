//
//  URLSessionHTTPClient.swift
//  URLSessionHTTPClient
//
//  Created by Elon on 12/08/2021.
//

import Foundation

public final class URLSessionHTTPClient: HTTPClient {
    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    struct UnExpectedValuesError: Error {}
    
    private struct Task: HTTPClientTask {
        let capturedTask: URLSessionDataTask
        
        func cancel() {
            capturedTask.cancel()
        }
    }
    
    public func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        let task = session.dataTask(with: url) { data, response, error in
            completion(Result {
                if let error = error {
                    throw error
                } else if let data = data, let response = response as? HTTPURLResponse {
                    return (data, response)
                } else {
                    throw UnExpectedValuesError()
                }
            })
        }
        
        task.resume()
        
        return Task(capturedTask: task)
    }
    
}
