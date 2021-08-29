//
//  FeedPresenterTests.swift
//  FeedPresenterTests
//
//  Created by Elon on 19/08/2021.
//

import XCTest
import EssentialFeed

class FeedPresenterTests: XCTestCase {
    
    func test_title_isLocalized() {
        XCTAssertEqual(FeedPresenter.title, localized("FEED_VIEW_TITLE"))
    }
    
    func test_map_createsViewModel() {
        let feed = uniqueImageFeed().models
        
        let viewModel = FeedPresenter.map(feed)
        
        XCTAssertEqual(viewModel.feed, feed)
    }
    
    // MARK: - Helpers
    private func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
        let table = "Feed"
        let bundle = Bundle(for: FeedPresenter.self)
        let localizedTitle = bundle.localizedString(forKey: key, value: nil, table: table)
        if key == localizedTitle {
            XCTFail("Missing localized string for key: \(key)", file: file, line: line)
        }
        
        return localizedTitle
    }
    
}
