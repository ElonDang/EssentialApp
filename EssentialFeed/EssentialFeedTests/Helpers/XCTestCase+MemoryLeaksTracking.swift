//
//  XCTestCase+MemoryLeaksTracking.swift
//  XCTestCase+MemoryLeaksTracking
//
//  Created by Elon on 12/08/2021.
//

import XCTest

extension XCTestCase {
    func trackMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Expected instance has been deallocated", file: file, line: line)
        }
    }
}
