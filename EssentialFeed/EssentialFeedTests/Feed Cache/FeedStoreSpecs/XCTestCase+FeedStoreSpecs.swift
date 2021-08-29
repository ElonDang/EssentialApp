//
//  XCTestCase+FeedStoreHelpers.swift
//  XCTestCase+FeedStoreHelpers
//
//  Created by Elon on 13/08/2021.
//

import XCTest
import EssentialFeed

extension FeedStoreSpecs where Self: XCTestCase {
    
    func assertThatRetrieveDeliversEmptyOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toRetrieve: .success(nil), file: file, line: line)
    }
    
    func assertThatRetrieveHasNoSideEffectsOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line){
        expect(sut, toRetrieveTwice: .success(nil), file: file, line: line)
    }
    
    func assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let local = uniqueImageFeed().local
        let currentDate = Date()
        
        insert((local: local, timestamp: currentDate), to: sut, file: file, line: line)
        expect(sut, toRetrieve: .success(CacheFeed(local, currentDate)), file: file, line: line)
    }
    
    func assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let local = uniqueImageFeed().local
        let currentDate = Date()
        
        insert((local: local, timestamp: currentDate), to: sut, file: file, line: line)
        expect(sut, toRetrieveTwice: .success(CacheFeed(local, currentDate)), file: file, line: line)
    }
    
    func assertThatInsertDeliversNoErrorOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        
        let firstLocal = uniqueImageFeed().local
        let firstTimestamp = Date()
        let firstInsertionError = insert((local: firstLocal, timestamp: firstTimestamp), to: sut, file: file, line: line)
        
        XCTAssertNil(firstInsertionError, file: file, line: line)
    }
    
    func assertThatInsertDeliversNoErrorOnNonEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        
        let firstLocal = uniqueImageFeed().local
        let firstTimestamp = Date()
        insert((local: firstLocal, timestamp: firstTimestamp), to: sut, file: file, line: line)
        
        
        let lastLocal = uniqueImageFeed().local
        let lastTimestamp = Date()
        let lastInsertionError = insert((local: lastLocal, timestamp: lastTimestamp), to: sut, file: file, line: line)
        
        XCTAssertNil(lastInsertionError)
    }
    
    func assertThatInsertOverridesPreviouslyInsertedCacheValues(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        
        let firstLocal = uniqueImageFeed().local
        let firstTimestamp = Date()
        insert((local: firstLocal, timestamp: firstTimestamp), to: sut, file: file, line: line)
        
        
        let lastLocal = uniqueImageFeed().local
        let lastTimestamp = Date()
        insert((local: lastLocal, timestamp: lastTimestamp), to: sut, file: file, line: line)
        
        expect(sut, toRetrieve: .success(CacheFeed(lastLocal, lastTimestamp)), file: file, line: line)
    }
    
    func assertThatDeleteDeliversNoErrorOnNonEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        insert((local: uniqueImageFeed().local, timestamp: Date()), to: sut, file: file, line: line)
        
        let deletionError = deleteCache(from: sut, file: file, line: line)
    
        XCTAssertNil(deletionError, file: file, line: line)
    }
    
    func assertThatDeleteEmptiesPreviouslyInsertedValuesOnNonEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        insert((local: uniqueImageFeed().local, timestamp: Date()), to: sut, file: file, line: line)
        
        deleteCache(from: sut, file: file, line: line)
    
        expect(sut, toRetrieve: .success(nil), file: file, line: line)
    }
    
    func assertThatDeleteDeliversNoErrorOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let deletionError = deleteCache(from: sut, file: file, line: line)
        
        XCTAssertNil(deletionError, file: file, line: line)
    }
    
    func assertThatDeleteHasNoSideEffectsOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        deleteCache(from: sut, file: file, line: line)
        
        expect(sut, toRetrieve: .success(nil), file: file, line: line)
    }
    
    func assertThatSideEffectsRunSerially(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        var completedOperationsOrder = [XCTestExpectation]()
        
        let op1 = expectation(description: "Operation 1")
        sut.insert(uniqueImageFeed().local, timestamp: Date()) { _ in
            completedOperationsOrder.append(op1)
            op1.fulfill()
        }
        
        let op2 = expectation(description: "Operation 2")
        sut.deleteCacheFeed() { _ in
            completedOperationsOrder.append(op2)
            op2.fulfill()
        }
        
        let op3 = expectation(description: "Operation 3")
        sut.insert(uniqueImageFeed().local, timestamp: Date()) { _ in
            completedOperationsOrder.append(op3)
            op3.fulfill()
        }
        
        waitForExpectations(timeout: 5.0, handler: nil)
        
        XCTAssertEqual(completedOperationsOrder, [op1, op2, op3], file: file, line: line)
    }
    
    func expect(_ sut: FeedStore, toRetrieveTwice expectedResult: FeedStore.RetrievalResult, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toRetrieve: expectedResult)
        expect(sut, toRetrieve: expectedResult)
    }
    
    func expect(_ sut: FeedStore, toRetrieve expectedResult: FeedStore.RetrievalResult, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "wait for completion")

        sut.retrieve { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(.some(receivedCache)), .success(.some(expectedCache))):
                XCTAssertEqual(receivedCache.feed, expectedCache.feed, file: file, line: line)
                XCTAssertEqual(receivedCache.timestamp, expectedCache.timestamp, file: file, line: line)
            case (.success, .success), (.failure, .failure) :
                break
            default:
                XCTFail("Expected \(expectedResult) but got \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    @discardableResult
    func insert(_ cache: (local: [LocalFeedImage], timestamp: Date), to sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) -> Error? {
        let exp = expectation(description: "wait for completion")
        
        var capturedError: Error?
        sut.insert(cache.local, timestamp: cache.timestamp) { insertionError in
            switch insertionError {
            case let .failure(error):
                capturedError = error
            case .success:
                break
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        return capturedError
    }
    
    @discardableResult
    func deleteCache(from sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) -> Error? {
        let exp = expectation(description: "wait for completion")
        
        var capturedError: Error?
        sut.deleteCacheFeed { deletionError in
            switch deletionError {
            case let .failure(error):
                capturedError = error
            case .success:
                break
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        return capturedError
    }
    
}
