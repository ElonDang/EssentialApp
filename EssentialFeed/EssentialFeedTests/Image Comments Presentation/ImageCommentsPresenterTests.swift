//
//  ImageCommentsPresenterTests.swift
//  ImageCommentsPresenterTests
//
//  Created by Elon on 27/08/2021.
//

import XCTest
import EssentialFeed

class ImageCommentsPresenterTests: XCTestCase {
    
    func test_title_isLocalized() {
        XCTAssertEqual(ImageCommentsPresenter.title, localized("IMAGE_COMMENTS_VIEW_TITLE"))
    }
    
    func test_map_createsViewModel() {
        let now = Date()
        let calendar = Calendar(identifier: .gregorian)
        let locale = Locale(identifier: "en_US_POSIX")
        let comments = [
            ImageComment(id: UUID(), message: "a message", createdAt: now.adding(seconds: -5, calendar: calendar), username: "a username"),
            ImageComment(id: UUID(), message: "another message", createdAt: now.adding(days: -1, calendar: calendar), username: "another username")
        ]
        
        let viewModels = ImageCommentsPresenter.map(
            comments,
            currentDate: now,
            calendar: calendar,
            locale: locale
        )
        
        XCTAssertEqual(viewModels.comments, [
            ImageCommentViewModel(message: "a message", createdAt: "5 seconds ago", username: "a username"),
            ImageCommentViewModel(message: "another message", createdAt: "1 day ago", username: "another username"),
        ])
    }
    
    // MARK: - Helpers
    private func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
        let table = "ImageComments"
        let bundle = Bundle(for: ImageCommentsPresenter.self)
        let localizedTitle = bundle.localizedString(forKey: key, value: nil, table: table)
        if key == localizedTitle {
            XCTFail("Missing localized string for key: \(key)", file: file, line: line)
        }
        
        return localizedTitle
    }
    
}
