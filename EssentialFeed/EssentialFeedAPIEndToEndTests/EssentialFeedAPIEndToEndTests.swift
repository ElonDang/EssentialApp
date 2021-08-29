//
//  EssentialFeedAPIEndToEndTests.swift
//  EssentialFeedAPIEndToEndTests
//
//  Created by Elon on 12/08/2021.
//

import XCTest
import EssentialFeed

class EssentialFeedAPIEndToEndTests: XCTestCase {
    
    private let baseURL = URL(string: "https://essentialdeveloper.com/feed-case-study/test-api/feed")!

    func test_loadFeed_receivesMatchedValuesWithAPIDataTest() {
        let session = URLSession(configuration: .ephemeral)
        let client = URLSessionHTTPClient(session: session)
        let testServerURL = baseURL
        
        trackMemoryLeaks(client)
        
        let exp = expectation(description: "wait for completion")
        var capturedResult: Swift.Result<[FeedImage], Error>?
        _ = client.get(from: testServerURL) { result in
            capturedResult = result.flatMap { (data, response) in
                do {
                    return .success(try FeedItemsMapper.map(data, response: response))
                } catch {
                    return .failure(error)
                }
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5.0)
        
        switch capturedResult {
        case let.success(imageFeed)?:
            XCTAssertEqual(imageFeed.count, 8)
        case let .failure(error)?:
            XCTFail("Exoected successful feed result, got \(error) instead")
        default:
            XCTFail("Exoected successful feed result, got no result instead")
        }
    }
    
    
    func test_loadFeedImageData_matchesFixedTestAccountData() {
        let testServerURL = baseURL.appendingPathComponent("73A7F70C-75DA-4C2E-B5A3-EED40DC53AA6/image")
        let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        let loader = RemoteFeedImageDataLoader(client: client)
        trackMemoryLeaks(client)
        trackMemoryLeaks(loader)
        
        let exp = expectation(description: "Wait for load completion")
        
        _ = loader.loadImageData(from: testServerURL) { result in
            switch result {
            case let .success(data):
                XCTAssertFalse(data.isEmpty, "Expected non-empty image data")
            case let .failure(error):
                XCTFail("Expected image data got \(error) instead")
            }
            
            exp.fulfill()
        }
        wait(for: [exp], timeout: 5.0)
        
    }
    
}
