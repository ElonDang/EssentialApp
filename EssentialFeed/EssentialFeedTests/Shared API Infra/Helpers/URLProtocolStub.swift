//
//  URLProtocolStub.swift
//  URLProtocolStub
//
//  Created by Elon on 20/08/2021.
//

import Foundation

class URLProtocolStub: URLProtocol {
    private struct Stub {
        let data: Data?
        let response: URLResponse?
        let error: Error?
        let requestObserver: ((URLRequest) -> Void)?
    }
    
    private static var _stub: Stub?
    private static let queue = DispatchQueue(label: "URLProtocolStub.queue")
    private static var stub: Stub? {
        get {
            return queue.sync { _stub }
        }
        set {
            queue.sync { _stub = newValue }
        }
    }
    
    static func startInterceptingRequests() {
        URLProtocol.registerClass(URLProtocolStub.self)
    }
    
    static func stopInterceptingRequests() {
        URLProtocol.unregisterClass(URLProtocolStub.self)
        removeStub()
    }
    
    static func observeRequest(response: @escaping (URLRequest) -> Void) {
        stub = .init(data: nil, response: nil, error: nil, requestObserver: response)
    }
    
    static func stub(data: Data?, response: URLResponse?, error: Error?) {
        stub = .init(data: data, response: response, error: error, requestObserver: nil)
    }
    
    private static func removeStub() {
        stub = nil
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        guard let stub = URLProtocolStub.stub else { return }
        
        if let data = stub.data {
            client?.urlProtocol(self, didLoad: data)
        }
        
        if let response = stub.response {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }
        
        if let error = stub.error {
            client?.urlProtocol(self, didFailWithError: error)
        } else {
            client?.urlProtocolDidFinishLoading(self)
        }
        
        stub.requestObserver?(request)
    }
    
    override func stopLoading() {}
}
