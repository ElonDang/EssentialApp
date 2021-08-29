//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class EssentialFeedCacheIntegrationTests: XCTestCase {

    override func setUp() {
        super.setUp()
        
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        
        undoStoreSideEffects()
    }
    
    // MARK: - LocalFeedLoader Tests
    
    func test_load_deliversNoItemsOnEmptyCache() {
        let feedLoader = makeFeedLoader()

        expect(feedLoader, toLoad: [])
    }
    
    func test_load_deliversItemsSavedOnASeparateInstance() {
        let feedLoaderToSave = makeFeedLoader()
        let feedLoaderToLoad = makeFeedLoader()
        let feed = uniqueImageFeed().models
        
        save(feed, with: feedLoaderToSave)

        expect(feedLoaderToLoad, toLoad: feed)
    }
    
    func test_save_overridesItemsSavedOnASeparateInstance() {
        let firstFeedLoaderToSave = makeFeedLoader()
        let secondFeedLoaderToSave = makeFeedLoader()
        let feedLoaderToLoad = makeFeedLoader()
        let firstFeed = uniqueImageFeed().models
        let latestFeed = uniqueImageFeed().models
        
        save(firstFeed, with: firstFeedLoaderToSave)
        save(latestFeed, with: secondFeedLoaderToSave)

        expect(feedLoaderToLoad, toLoad: latestFeed)
    }
    
    func test_validateFeedCache_doesNotDeleteNonExpiredCache() {
        let feedLoaderToPerformSave = makeFeedLoader()
        let feedLoaderToPerformValidate = makeFeedLoader()
        let feedLoaderToPerformLoad = makeFeedLoader()
        let feed = uniqueImageFeed().models
        
        save(feed, with: feedLoaderToPerformSave)
        validateCache(with: feedLoaderToPerformValidate)
        
        expect(feedLoaderToPerformLoad, toLoad: feed)
    }
    
    func test_validateFeedCache_deletesExpiredCache() {
        let feedLoaderToPerformSave = makeFeedLoader(currentDate: { Date.distantPast })
        let feedLoaderToPerformValidate = makeFeedLoader(currentDate: { Date() })
        let feedLoaderToPerformLoad = makeFeedLoader()
        let feed = uniqueImageFeed().models
        
        save(feed, with: feedLoaderToPerformSave)
        validateCache(with: feedLoaderToPerformValidate)
        
        expect(feedLoaderToPerformLoad, toLoad: [])
    }
    
    // MARK: - LocalFeedImageDataLoader Tests
    
    func test_loadImageData_deliversSaveDataOnASeprateInstance() {
        let imageLoaderToSave = makeImageLoader()
        let imageLoaderToLoad = makeImageLoader()
        let feedLoader = makeFeedLoader()
        let feedImage = uniqueImageFeed().models
        let dataToSave = anyData()
        let url = anyURL()
        
        save(feedImage, with: feedLoader)
        save(dataToSave, for: url, with: imageLoaderToSave)
        expect(imageLoaderToLoad, toLoad: dataToSave, for: url)
    }
    
    func test_loadImageData_deliversLastSavedDataForURLOnSeparatedInstance() {
        let firstImageLoaderToSave = makeImageLoader()
        let secondImageLoaderToSave = makeImageLoader()
        let imageLoaderToLoad = makeImageLoader()
        let feedLoader = makeFeedLoader()
        let feedImage = uniqueImageFeed().models
        let fisrtDataToSave = Data("first data".utf8)
        let lastDataToSave = Data("last data".utf8)
        let url = anyURL()
        
        save(feedImage, with: feedLoader)
        save(fisrtDataToSave, for: url, with: firstImageLoaderToSave)
        save(lastDataToSave, for: url, with: secondImageLoaderToSave)

        expect(imageLoaderToLoad, toLoad: lastDataToSave, for: url)
    }
    
    // MARK: Helpers
    private func makeFeedLoader(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> LocalFeedLoader {
        let storeURL = testSpecificStoreURL()
        let store = try! CoreDataFeedStore(storeURL: storeURL)
        let feedLoader = LocalFeedLoader(store: store, currentDate: currentDate)
        trackMemoryLeaks(store, file: file, line: line)
        trackMemoryLeaks(feedLoader, file: file, line: line)
        return feedLoader
    }
    
    private func makeImageLoader(file: StaticString = #file, line: UInt = #line) -> LocalFeedImageDataLoader {
        let storeURL = testSpecificStoreURL()
        let store = try! CoreDataFeedStore(storeURL: storeURL)
        let imageDataLoader = LocalFeedImageDataLoader(store: store)
        trackMemoryLeaks(store, file: file, line: line)
        trackMemoryLeaks(imageDataLoader, file: file, line: line)
        return imageDataLoader
    }
    
    private func anyData() -> Data {
        Data("any data".utf8)
    }
    
    private func save(_ feed: [FeedImage], with loader: LocalFeedLoader, file: StaticString = #file, line: UInt = #line) {
        let saveExp = expectation(description: "Wait for save completion")
        loader.save(feed) { saveError in
            switch saveError {
            case let .failure(error):
                XCTFail("Expected to save feed successfully but got \(error) instead", file: file, line: line)
            default: break
            }
            saveExp.fulfill()
        }
        wait(for: [saveExp], timeout: 1.0)
    }
    
    private func expect(_ loader: LocalFeedLoader, toLoad expectedFeed: [FeedImage], file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        loader.load { result in
            switch result {
            case let .success(loadedFeed):
                XCTAssertEqual(loadedFeed, expectedFeed, file: file, line: line)
                
            case let .failure(error):
                XCTFail("Expected successful feed result, got \(error) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    private func validateCache(with loader: LocalFeedLoader, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for validate cache completion")
        loader.validateCache { result in
            if case let Result.failure(error) = result {
                XCTFail("Expected success but got \(error) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    private func save(_ data: Data, for url: URL, with loader: LocalFeedImageDataLoader, file: StaticString = #file, line: UInt = #line) {
        let saveExp = expectation(description: "Wait for save completion")
        
        loader.save(data, for: url) { result in
            if case let Result.failure(error) = result {
                XCTFail("Expected success but got \(error) instead", file: file, line: line)
            }
            saveExp.fulfill()
        }
        wait(for: [saveExp], timeout: 1.0)
    }
    
    private func expect(_ loader: LocalFeedImageDataLoader, toLoad expectedData: Data, for url: URL, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        _ = loader.loadImageData(from: url) { result in
            switch result {
            case let .success(data):
                XCTAssertEqual(data, expectedData, file: file, line: line)
            case let .failure(error):
                XCTFail("Expected successful feed result, got \(error) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    private func setupEmptyStoreState() {
        deleteStoreArtifacts()
    }
    
    private func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }
    
    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
    
    private func testSpecificStoreURL() -> URL {
        return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
    }
    
    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    func anyURL() -> URL {
        URL(string: "https://any-url.com")!
    }

    func uniqueImage() -> FeedImage {
        FeedImage(id: UUID(), description: "any", location: "any", url: anyURL())
    }

    func uniqueImageFeed() -> (models: [FeedImage], local: [LocalFeedImage]) {
        let feed = [uniqueImage(), uniqueImage()]
        let local = feed.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
        
        return (feed, local)
    }
}
