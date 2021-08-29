//
//  TestHelpers.swift
//  TestHelpers
//
//  Created by Elon on 22/08/2021.
//

import Foundation

func anyURL() -> URL {
    URL(string: "https://any-url.com")!
}

func anyNSError() -> NSError {
    NSError(domain: "test", code: 0, userInfo: nil)
}
