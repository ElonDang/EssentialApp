//
//  CacheFeedImageDataUseCaseTests.swift
//  CacheFeedImageDataUseCaseTests
//
//  Created by Elon on 20/08/2021.
//

import XCTest
import EssentialFeed

class CacheFeedImageDataUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStore() {
        let (_, store) = makeSUT()
        
        XCTAssertTrue(store.messages.isEmpty)
    }
    
    func test_save_storesDataForURL() {
        let (sut, store) = makeSUT()
        let data = anyData()
        let url = anyURL()
        
        sut.save(data, for: url) {_ in}
        
        XCTAssertEqual(store.messages, [.store(data: data, for: url)])
    }
    
    func test_save_deliversErrorOnSavingError() {
        let (sut, store) = makeSUT()
               
        expect(sut, toCompleteWith: .failure(LocalFeedImageDataLoader.SaveError.failed)) {
            store.completeImageDataInsertion(with: anyNSError())
        }
        
    }
    
    func test_save_succeedsOnSavingImageDataSuccessful() {
        let (sut, store) = makeSUT()

        expect(sut, toCompleteWith: .success(())) {
            store.completeImageDataInsertionSuccessful()
        }
    }
    
    func test_save_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let store = FeedImageDataStoreSpy()
        var sut: LocalFeedImageDataLoader? = LocalFeedImageDataLoader(store: store)
        
        var capturedResult: LocalFeedImageDataLoader.SaveResult?
        sut?.save(anyData(), for: anyURL()) { capturedResult = $0 }
        
        sut = nil
        store.completeImageDataInsertionSuccessful()
        
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
    
    private func expect(_ sut: LocalFeedImageDataLoader, toCompleteWith expectedResult: LocalFeedImageDataLoader.SaveResult, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "wait for completion")

        sut.save(anyData(), for: anyURL()) { receivedResult in
            switch (receivedResult, expectedResult) {
            case (.success, .success):
                break
            case let (.failure(receivedError as LocalFeedImageDataLoader.SaveError), .failure(expectedError as LocalFeedImageDataLoader.SaveError)):
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
