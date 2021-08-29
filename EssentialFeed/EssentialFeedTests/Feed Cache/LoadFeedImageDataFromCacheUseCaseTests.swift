//
//  LocalFeedImageDataLoaderTests.swift
//  LocalFeedImageDataLoaderTests
//
//  Created by Elon on 20/08/2021.
//

import XCTest
import EssentialFeed

class LoadFeedImageDataFromCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStore() {
        let (_, store) = makeSUT()
        
        XCTAssertTrue(store.messages.isEmpty)
    }
    
    func test_loadImageData_requestsStoreDataForURL() {
        let (sut, store) = makeSUT()
        
        let url = anyURL()
        _ = sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(store.messages, [.retrieve(url)])
    }
    
    func test_loadImageData_deliversErrorOnRetrievalError() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(LocalFeedImageDataLoader.LoadError.failed)) {
            store.completeImageDataLoading(with: anyNSError())
        }
    }
    
    func test_loadImageData_deliversErrorOnStoreNotFound() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(LocalFeedImageDataLoader.LoadError.notFound)) {
            store.completeImageDataLoading(with: .none)
        }
    }
    
    func test_loadImageData_deliversStoredDataForURL() {
        let (sut, store) = makeSUT()
        let imageData = anyData()
        
        expect(sut, toCompleteWith: .success(imageData)) {
            store.completeImageDataLoading(with: imageData)
        }
    }
    
    func test_loadImageData_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let store = FeedImageDataStoreSpy()
        var sut: LocalFeedImageDataLoader? = LocalFeedImageDataLoader(store: store)
        
        var capturedResult: LocalFeedImageDataLoader.LoadResult?
        _ = sut?.loadImageData(from: anyURL()) { capturedResult = $0 }
        
        sut = nil
        store.completeImageDataLoading(with: anyNSError())
        
        XCTAssertNil(capturedResult)
    }
    
    func test_loadImageData_doesNotDeliverResultAfterCancelLoad() {
        let store = FeedImageDataStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        
        var capturedResult: LocalFeedImageDataLoader.LoadResult?
        let task = sut.loadImageData(from: anyURL()) { capturedResult = $0 }
        
        task.cancel()
        store.completeImageDataLoading(with: anyNSError())
        store.completeImageDataLoading(with: .none)
        store.completeImageDataLoading(with: anyData())
        
        XCTAssertNil(capturedResult)
    }
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedImageDataLoader, store: FeedImageDataStoreSpy) {
        let store = FeedImageDataStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        trackMemoryLeaks(store, file: file, line: line)
        trackMemoryLeaks(sut, file: file, line: line)
        
        return (sut, store)
    }
    
    private func expect(_ sut: LocalFeedImageDataLoader, toCompleteWith expectedResult: LocalFeedImageDataLoader.LoadResult, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "wait for completion")

        _ = sut.loadImageData(from: anyURL()) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedFeed), .success(expectedFeed)):
                XCTAssertEqual(receivedFeed, expectedFeed, file: file, line: line)
            case let (.failure(receivedError as LocalFeedImageDataLoader.LoadError), .failure(expectedError as LocalFeedImageDataLoader.LoadError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected \(expectedResult) got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        action()

        wait(for: [exp], timeout: 1.0)
    }
    
}
