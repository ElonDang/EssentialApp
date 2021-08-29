//
//  XCTestCase+FailableDeleteFeedStoreSpecs.swift
//  XCTestCase+FailableDeleteFeedStoreSpecs
//
//  Created by Elon on 13/08/2021.
//

import XCTest
import EssentialFeed

extension FailableDeleteFeedStoreSpecs where Self: XCTestCase {
    
    func assertThatDeleteDeliversErrorOnDeletionError(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        insert((local: uniqueImageFeed().local, timestamp: Date()), to: sut, file: file, line: line)

        let deletionError = deleteCache(from: sut, file: file, line: line)
        XCTAssertNotNil(deletionError, file: file, line: line)
    }
    
    func assertThatDeleteHasNoSideEffectsOnDeletionError(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let local = uniqueImageFeed().local
        let timestamp = Date()

        insert((local: local, timestamp: timestamp), to: sut, file: file, line: line)

        deleteCache(from: sut, file: file, line: line)
        
        expect(sut, toRetrieve: .success(CacheFeed(local, timestamp)), file: file, line: line)
    }
}

