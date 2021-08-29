//
//  XCTestCase+FailableInsertFeedStoreSpecs.swift
//  XCTestCase+FailableInsertFeedStoreSpecs
//
//  Created by Elon on 13/08/2021.
//

import XCTest
import EssentialFeed

extension FailableInsertFeedStoreSpecs where Self: XCTestCase {
    func assertThatInsertDeliversErrorOnInsertionError(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let firstInsertionError = insert((local: uniqueImageFeed().local, timestamp: Date()), to: sut)
        XCTAssertNotNil(firstInsertionError, file: file, line: line)
    }
    
    func assertThatInsertHasNoSideEffectsOnInsertionError(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        insert((local: uniqueImageFeed().local, timestamp: Date()), to: sut, file: file, line: line)
        
        expect(sut, toRetrieve: .success(nil), file: file, line: line)
    }
}
