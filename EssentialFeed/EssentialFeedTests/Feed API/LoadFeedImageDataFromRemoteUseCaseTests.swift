//
//  LoadFeedImageDataFromRemoteUseCaseTests.swift
//  LoadFeedImageDataFromRemoteUseCaseTests
//
//  Created by Elon on 20/08/2021.
//

import XCTest
import EssentialFeed

class LoadFeedImageDataFromRemoteUseCaseTests: XCTestCase {
    
    func test_init_doesNotLoadDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_loadImageData_loadsDataFromURL() {
        let (sut, client) = makeSUT()
        let url = anyURL()
        
        _ = sut.loadImageData(from: url) {_ in}
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadImageDataTwice_loadsDataFromURLTwice() {
        let (sut, client) = makeSUT()
        let url = anyURL()
        
        _ = sut.loadImageData(from: url) {_ in}
        _ = sut.loadImageData(from: url) {_ in}

        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_loadImageData_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
                
        expect(sut, toCompleteWithResult: .failure(RemoteFeedImageDataLoader.Error.connectivity)) {
            client.complete(with: anyNSError())
        }
    }
    
    func test_loadImageData_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        let samples = [199, 201, 300, 400]
                
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWithResult: .failure(RemoteFeedImageDataLoader.Error.invalidData)) {
                let json = anyData()
                client.complete(withStatusCode: code, data: json, at: index)
            }
        }
    }
    
    func test_loadImageData_deliversErrorOn200HTTPResponseAndEmptyData() {
        let (sut, client) = makeSUT()
        
        let emptyData = Data(count: 0)
        expect(sut, toCompleteWithResult: .failure(RemoteFeedImageDataLoader.Error.invalidData)) {
            client.complete(withStatusCode: 200, data: emptyData)
        }
    }
    
    func test_loadImageData_succeedsOn200HTTPResponseWithData() {
        let (sut, client) = makeSUT()
        
        let nonEmptyData = Data("image-data".utf8)
        expect(sut, toCompleteWithResult: .success(nonEmptyData)) {
            client.complete(withStatusCode: 200, data: nonEmptyData)
        }
    }
    
    func test_loadImageData_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let client = HTTPClientSpy()
        var sut: RemoteFeedImageDataLoader? = RemoteFeedImageDataLoader(client: client)
        
        var capturedResult: RemoteFeedImageDataLoader.Result?
        _ = sut?.loadImageData(from: anyURL()) {
            capturedResult = $0
        }
        
        sut = nil
        client.complete(with: anyNSError())
        
        XCTAssertNil(capturedResult)
    }
    
    func test_cancelLoadIamgeData_cancelsClientURLRequest() {
        let (sut, client) = makeSUT()
        let url = anyURL()

        let task = sut.loadImageData(from: url) {_ in }
        
        task.cancel()
        
        XCTAssertEqual(client.cancelledImageURLs, [url])
    }
    
    func test_cancelLoadIamgeData_doesNotDeliverResultWhenCancel() {
        let (sut, client) = makeSUT()
        let url = anyURL()

        var capturedResult: FeedImageDataLoader.Result?
        let task = sut.loadImageData(from: url) { capturedResult = $0 }
        
        task.cancel()
        client.complete(withStatusCode: 200, data: anyData())
        
        XCTAssertNil(capturedResult)
    }
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteFeedImageDataLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedImageDataLoader(client: client)
        
        trackMemoryLeaks(sut, file: file, line: line)
        trackMemoryLeaks(client, file: file, line: line)
        
        return (sut, client)
    }
    
    private func expect(_ sut: RemoteFeedImageDataLoader, toCompleteWithResult expectedResult: RemoteFeedImageDataLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        
        let exp = expectation(description: "wait for completion")
        
        _ = sut.loadImageData(from: anyURL()) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.failure(receivedError as RemoteFeedImageDataLoader.Error), .failure(expectedError as RemoteFeedImageDataLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
            default:
                XCTFail("Expected \(expectedResult) but got \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
                
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
}
