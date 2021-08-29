//
//  ImageCommentsMapperTests.swift
//  ImageCommentsMapperTests
//
//  Created by Elon on 25/08/2021.
//

import XCTest
import EssentialFeed

class ImageCommentsMapperTests: XCTestCase {
    
    func test_map_throwsErrorOnNon2xxHTTPResponse() throws {
        let json = makeItemsJSON([])
        
        let samples = [150, 199, 300, 400, 500]
        
        try samples.forEach { code in
            XCTAssertThrowsError(try ImageCommentsMapper.map(json, response: HTTPURLResponse(statusCode: code)))
        }
    }
    
    func test_map_throwsErrorOn2xxHTTPResponseWithInvalidJSON() throws {
        let invalidJSON = Data("invalid json".utf8)
        
        let samples = [200, 201, 230, 250, 299]
        
        try samples.forEach { code in
            XCTAssertThrowsError(try ImageCommentsMapper.map(invalidJSON, response: HTTPURLResponse(statusCode: code)))
        }
    }
    
    func test_map_returnsNoItesmOn2xxHTTPResponseWithEmptyList() throws {
        let emptyJSON = makeItemsJSON([])

        let samples = [200, 201, 230, 250, 299]

        try samples.forEach { code in
            let items = try ImageCommentsMapper.map(emptyJSON, response: HTTPURLResponse(statusCode: code))
            XCTAssertTrue(items.isEmpty)
        }
    }
    
    func test_map_returnsItesmOn2xxHTTPResponseWithJSONItems() throws {
        let item1 = makeItem(id: UUID(),
                             message: "a message",
                             createdAt: (Date(timeIntervalSince1970: 1598627222), "2020-08-28T15:07:02+00:00"),
                             username: "ussername")
                
        let item2 = makeItem(id: UUID(),
                             message: "another message",
                             createdAt: (Date(timeIntervalSince1970: 1577881882), "2020-01-01T12:31:22+00:00"),
                             username: "another username")
        
        let samples = [200, 201, 230, 250, 299]
        let json = makeItemsJSON([item1.json, item2.json])
        
        try samples.forEach { code in
            let items = try ImageCommentsMapper.map(json, response: HTTPURLResponse(statusCode: code))
            XCTAssertEqual(items, [item1.model, item2.model])
        }
    }
    
    // MARK: - Helpers
    private func makeItem(id: UUID, message: String, createdAt: (date: Date, iso8601String: String), username: String) -> (model: ImageComment, json: [String: Any]) {
        let item = ImageComment(id: id, message: message, createdAt: createdAt.date, username: username)
        let json: [String: Any] = [
            "id": item.id.uuidString,
            "message": item.message,
            "created_at": createdAt.iso8601String,
            "author": [
                "username": item.username
            ]
        ]
        
        return (item, json)
    }
}
