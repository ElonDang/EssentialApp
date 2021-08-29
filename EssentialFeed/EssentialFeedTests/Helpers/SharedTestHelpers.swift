//
//  SharedTestHelpers.swift
//  SharedTestHelpers
//
//  Created by Elon on 13/08/2021.
//

import Foundation

func anyNSError() -> NSError {
    NSError(domain: "test", code: 0, userInfo: nil)
}

func anyURL() -> URL {
    URL(string: "https://any-url.com")!
}

func anyData() -> Data {
    Data("any data".utf8)
}

func makeItemsJSON(_ items: [[String: Any]]) -> Data {
    let itemsJSON = ["items": items]

    return try! JSONSerialization.data(withJSONObject: itemsJSON)
}
