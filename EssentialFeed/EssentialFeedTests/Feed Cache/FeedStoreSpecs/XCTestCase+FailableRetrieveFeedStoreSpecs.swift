//
//  XCTestCase+FailableRetrieveFeedStoreSpecs.swift
//  XCTestCase+FailableRetrieveFeedStoreSpecs
//
//  Created by Elon on 13/08/2021.
//

import XCTest
import EssentialFeed

extension FailableRetrieveFeedStoreSpecs where Self: XCTestCase {
    func assertThatRetrieveDeliversErrorOnRetrievalError(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        
        expect(sut, toRetrieve: .failure(anyNSError()), file: file, line: line)
    }
    
    func assertThatRetrieveHasNoSideEffectsOnRetrievalError(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        
        expect(sut, toRetrieveTwice: .failure(anyNSError()), file: file, line: line)
    }
}
