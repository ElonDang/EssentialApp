//
//  ValidateFeedCacheUseCaseTests.swift
//  ValidateFeedCacheUseCaseTests
//
//  Created by Elon on 13/08/2021.
//

import XCTest
import EssentialFeed

class ValidateFeedCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageTheStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_validateCache_deletesCachedFeedOnRetrievalError() {
        let (sut, store) = makeSUT()
        
        sut.validateCache() {_ in}
        store.completeRetrieval(with: anyNSError())
        
        XCTAssertEqual(store.receivedMessages, [.retrieval, .deleteCachedFeed])
    }
    
    func test_validateCache_doesNotDeleteCacheOnEmptyCache() {
        let (sut, store) = makeSUT()
        
        sut.validateCache() {_ in}
        store.completeRetrievalSuccessfulWithEmptyCache()
        
        XCTAssertEqual(store.receivedMessages, [.retrieval])
    }

    func test_validateCache_doesNotDeleteCacheOnNonExpiredCache() {
        let fixedCurrentDate = Date()
        let nonExpiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)
        let (sut, store) = makeSUT { fixedCurrentDate }
        
        sut.validateCache() {_ in}
        store.completeRetrievalSuccessful(with: uniqueImageFeed().local, timestamp: nonExpiredTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieval])
    }
    
    func test_validateCache_deletesCacheOnExpirationCache() {
        let fixedCurrentDate = Date()
        let expirationTimestamp = fixedCurrentDate.minusFeedCacheMaxAge()
        let (sut, store) = makeSUT { fixedCurrentDate }
        
        sut.validateCache() {_ in}
        store.completeRetrievalSuccessful(with: uniqueImageFeed().local, timestamp: expirationTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieval, .deleteCachedFeed])
    }
    
    func test_validateCache_deletesCacheOnExpiredCache() {
        let fixedCurrentDate = Date()
        let expiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
        let (sut, store) = makeSUT { fixedCurrentDate }
        
        sut.validateCache() {_ in}
        store.completeRetrievalSuccessful(with: uniqueImageFeed().local, timestamp: expiredTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieval, .deleteCachedFeed])
    }
    
    func test_validateCache_doesNotDeleteCacheAfterSUTInstanceHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        sut?.validateCache() {_ in}
        sut = nil
        store.completeRetrieval(with: anyNSError())
        
        XCTAssertEqual(store.receivedMessages, [.retrieval])
    }
    
    func test_validateCache_failsOnDeletionErrorOfFailedRetrieval() {
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()
        
        expect(sut, toCompleteWithResult: .failure(deletionError)) {
            store.completeRetrieval(with: anyNSError())
            store.completeDeletion(with: deletionError)
        }
    }
    
    func test_validateCache_succeedsOnSuccessfulDeletionOfFailedRetrieval() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWithResult: .success(())) {
            store.completeRetrieval(with: anyNSError())
            store.completeDeletionSuccessfully()
        }
    }
    
    func test_validateCache_succeedsOnEmptyCache() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWithResult: .success(())) {
            store.completeRetrievalSuccessfulWithEmptyCache()
        }
    }
    
    func test_validateCache_succeedsOnNonExpiredCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let nonExpiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        expect(sut, toCompleteWithResult: .success(()), when: {
            store.completeRetrievalSuccessful(with: feed.local, timestamp: nonExpiredTimestamp)
        })
    }
    
    func test_validateCache_failssOnDeletionErrorOfExpiredCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let expiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        let deletionError = anyNSError()

        expect(sut, toCompleteWithResult: .failure(deletionError), when: {
            store.completeRetrievalSuccessful(with: feed.local, timestamp: expiredTimestamp)
            store.completeDeletion(with: deletionError)
        })
    }
    
    func test_validateCache_succeedsOnSuccessfulDeletionOfExpiredCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let expiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

        expect(sut, toCompleteWithResult: .success(()), when: {
            store.completeRetrievalSuccessful(with: feed.local, timestamp: expiredTimestamp)
            store.completeDeletionSuccessfully()
        })
    }

    // MARK: - Helpers
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) ->  (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackMemoryLeaks(store, file: file, line: line)
        trackMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func expect(_ sut: LocalFeedLoader, toCompleteWithResult expectedResult: LocalFeedLoader.ValidateResult, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for validate cache completion")
        sut.validateCache { receivedResult in
            switch (expectedResult, receivedResult) {
            case (.failure, .failure), (.success, .success):
                break
            default:
                XCTFail("Expected \(expectedResult) but got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
}
