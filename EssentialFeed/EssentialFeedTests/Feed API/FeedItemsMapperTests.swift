//
//  RemoteFeedLoaderTests.swift
//  RemoteFeedLoaderTests
//
//  Created by Elon on 12/08/2021.
//

import Foundation
import XCTest
import EssentialFeed

class FeedItemsMapperTests: XCTestCase {
    
    func test_map_throwsErrorOnNon200HTTPResponse() throws {
        let samples = [199, 201, 300, 400]
        let json = makeItemsJSON([])

        try samples.forEach { code in
            let response = HTTPURLResponse(statusCode: code)
            XCTAssertThrowsError(try FeedItemsMapper.map(json, response: response))
        }
    }
    
    func test_map_throwsErrorOn200HTTPResponseWithInvalidJSON() {
        let invalidJSON = Data("invalid json".utf8)
        
        XCTAssertThrowsError(try FeedItemsMapper.map(invalidJSON, response: HTTPURLResponse(statusCode: 200)))
    }
    
    func test_map_returnsNoItesmOn200HTTPResponseWithEmptyList() {
        let emptyJSON = makeItemsJSON([])

        let items = try! FeedItemsMapper.map(emptyJSON, response: HTTPURLResponse(statusCode: 200))
        XCTAssertTrue(items.isEmpty)
    }
    
    func test_map_returnsItesmOn200HTTPResponseWithJSONItems() {
        let item1 = makeItem(id: UUID(),
                             description: nil,
                             location: nil,
                             imageURL: URL(string: "https://image-1.com")!)
                
        let item2 = makeItem(id: UUID(),
                             description: "a description",
                             location: "a location",
                             imageURL: URL(string: "https://image-2.com")!)
        
        let json = makeItemsJSON([item1.json, item2.json])
        let items = try! FeedItemsMapper.map(json, response: HTTPURLResponse(statusCode: 200))
        
        XCTAssertEqual(items, [item1.model, item2.model])
    }
    
    // MARK: - Helpers
    private func makeItem(id: UUID, description: String?, location: String?, imageURL: URL) -> (model: FeedImage, json: [String: Any]) {
        let item = FeedImage(id: id, description: description, location: location, url: imageURL)
        let json = [
            "id": item.id.uuidString,
            "description": item.description,
            "location": item.location,
            "image": item.url.absoluteString
        ].compactMapValues({$0})
        
        return (item, json)
    }
}
