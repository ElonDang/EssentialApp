//
//  URLSessionHTTPClientTests.swift
//  URLSessionHTTPClientTests
//
//  Created by Elon on 12/08/2021.
//

import XCTest
import EssentialFeed

class URLSessionHTTPClientTests: XCTestCase {

    override func setUp() {
        super.setUp()
        
        URLProtocolStub.startInterceptingRequests()
    }
    
    override func tearDown() {
        super.tearDown()
        
        URLProtocolStub.stopInterceptingRequests()
    }
    
    func test_getFromURL_requestsFromTheGivenURL() {
        let url = anyURL()
        let sut = makeSUT()
        
        let exp = expectation(description: "Wait for completion")
        URLProtocolStub.observeRequest { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        
        _ = sut.get(from: url) { _ in }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_getFromURL_failsOnRequestError() {
        let error = NSError(domain: "test", code: 1, userInfo: nil)
        let receivedError = resultError(data: nil, response: nil, error: error)
        
        XCTAssertEqual(receivedError?.domain, error.domain)
        XCTAssertEqual(receivedError?.code, error.code)
    }
    
    func test_getFromURL_failsOnInvalidPresentationValues() {
        XCTAssertNotNil(resultError(data: nil, response: nil, error: nil))
        XCTAssertNotNil(resultError(data: anyData(), response: nil, error: nil))
        XCTAssertNotNil(resultError(data: anyData(), response: nonHTTPURLResponse(), error: nil))
        XCTAssertNotNil(resultError(data: anyData(), response: nonHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultError(data: anyData(), response: anyHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultError(data: nil, response: nonHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultError(data: nil, response: anyHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultError(data: anyData(), response: nil, error: anyNSError()))
    }
    
    func test_getFromURL_succeedsWithEmptyDataOnHTTPURLResponseWithEmptyData() {
        let (data, response) = resultValues(data: nil, response: anyHTTPURLResponse(), error: nil)
        
        let emptyData = Data(count: 0)
        XCTAssertEqual(data, emptyData)
        XCTAssertEqual(response.url, response.url)
        XCTAssertEqual(response.statusCode, response.statusCode)
    }
    
    func test_getFromURL_succeedsOnValidResponse() {
        let (data, response) = resultValues(data: anyData(), response: anyHTTPURLResponse(), error: nil)
        
        XCTAssertEqual(data, data)
        XCTAssertEqual(response.url, response.url)
        XCTAssertEqual(response.statusCode, response.statusCode)
    }
    
    func test_cancel_deliversErrorOnCancelLoad() {
        let sut = makeSUT()
        
        let exp = expectation(description: "Wait for completion")
        var capturedError: URLError?
        let task = sut.get(from: anyURL()) { result in
            switch result {
            case let .failure(error as URLError):
                capturedError = error
            default:
                XCTFail("Expected cancelled error but got \(result) instead")
            }
            
            exp.fulfill()
        }
        
        task.cancel()
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(capturedError?.errorCode, URLError.cancelled.rawValue)
    }
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> URLSessionHTTPClient {
        let sut = URLSessionHTTPClient()
        trackMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func resultError(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line) -> NSError? {
        let sut = makeSUT()
        URLProtocolStub.stub(data: data, response: response, error: error)

        var capturedError: NSError?
        let exp = expectation(description: "Wait for completion")
        _ = sut.get(from: anyURL()) { result in
            switch result {
            case let .failure(error as NSError):
                capturedError = error
            case .success:
                XCTFail("Expected failure but got \(result) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        return capturedError
    }
    
    private func resultValues(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line) -> (data: Data, response: HTTPURLResponse) {
        let sut = makeSUT()
        URLProtocolStub.stub(data: data, response: response, error: error)

        var capturedValues: (data: Data, response: HTTPURLResponse)!
        let exp = expectation(description: "Wait for completion")
        _ = sut.get(from: anyURL()) { result in
            switch result {
            case let .success((data, response)):
                capturedValues = (data, response)
            case .failure:
                XCTFail("Expected success but got \(result) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        return capturedValues
    }
    
    private func nonHTTPURLResponse() -> URLResponse {
        URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    private func anyHTTPURLResponse() -> HTTPURLResponse {
        HTTPURLResponse(url: anyURL(), statusCode: 0, httpVersion: nil, headerFields: nil)!
    }
}
