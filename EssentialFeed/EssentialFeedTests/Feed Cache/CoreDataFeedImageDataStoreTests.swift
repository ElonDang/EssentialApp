//
//  CoreDataFeedImageDataStoreTests.swift
//  CoreDataFeedImageDataStoreTests
//
//  Created by Elon on 20/08/2021.
//

import XCTest
import EssentialFeed

class CoreDataFeedImageDataStoreTests: XCTestCase {
    
    func test_retrieveDataForURL_deliversEmptyOnEmptyStore() {
        let sut = makeSUT()
        
        expect(sut, toCompleteRetrievalWith: notFound(), for: anyURL())
    }
    
    func test_retrieveDataForURL_deliversErrorOnURLNotFound() {
        let sut = makeSUT()
        let url = URL(string: "http://a-url.com")!
        let nonMatchingURL = URL(string: "http://another-url.com")!
        
        insert(anyData(), for: nonMatchingURL, into: sut)
        
        expect(sut, toCompleteRetrievalWith: notFound(), for: url)
    }
    
    func test_retrieveImageData_deliversFoundDataWhenThereIsAStoredImageDataMatchingURL() {
        let sut = makeSUT()
        let storedData = anyData()
        let matchingURL = URL(string: "http://a-url.com")!
        
        insert(storedData, for: matchingURL, into: sut)
        
        expect(sut, toCompleteRetrievalWith: found(storedData), for: matchingURL)
    }
    
    func test_retrieveImageData_deliversLastSavedData() {
        let sut = makeSUT()
        let fistSavedData = Data("first saved".utf8)
        let lastSavedData = Data("last saved".utf8)
        let matchingURL = URL(string: "http://a-url.com")!
        
        insert(fistSavedData, for: matchingURL, into: sut)
        insert(lastSavedData, for: matchingURL, into: sut)

        expect(sut, toCompleteRetrievalWith: found(lastSavedData), for: matchingURL)
    }
    
    func test_sideEffects_runSerially() {
        let sut = makeSUT()
        let url = anyURL()
        let image = LocalFeedImage(id: UUID(), description: "any", location: "any", url: url)

        let op1 = expectation(description: "Operation 1")
        sut.insert([image], timestamp: Date()) { _ in
            op1.fulfill()
        }
        
        let op2 = expectation(description: "Operation 2")
        sut.insert(anyData(), for: url) { _ in    op2.fulfill() }
        
        let op3 = expectation(description: "Operation 3")
        sut.insert(anyData(), for: url) { _ in op3.fulfill() }
        
        wait(for: [op1, op2, op3], timeout: 5.0, enforceOrder: true)
    }
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> CoreDataFeedStore {
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try! CoreDataFeedStore(storeURL: storeURL)
        trackMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func found(_ data: Data) -> FeedImageDataStore.RetrievalResult {
        return .success(data)
    }
    
    private func notFound() -> FeedImageDataStore.RetrievalResult {
        return .success(.none)
    }
    
    private func failed() -> FeedImageDataStore.RetrievalResult {
        return .failure(anyNSError())
    }
    
    private func expect(_ sut: CoreDataFeedStore, toCompleteRetrievalWith expectedResult: FeedImageDataStore.RetrievalResult, for url: URL, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        sut.retrieve(dataForURL: url) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success( receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)
                
            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    private func insert(_ data: Data, for url: URL, into sut: CoreDataFeedStore, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        let image = LocalFeedImage(id: UUID(), description: "any", location: "any", url: url)
        sut.insert([image], timestamp: Date()){ result in
            switch result {
            case let .failure(error):
                XCTFail("Expected success but got \(error) instead", file: file, line: line)
                exp.fulfill()
            case .success:
                sut.insert(data, for: url) { result in
                    if case let Result.failure(error) = result {
                        XCTFail("Expected success but got \(error) instead", file: file, line: line)
                    }
                    exp.fulfill()
                }
            }
        }
        
        wait(for: [exp], timeout: 1.0)
    }
}
