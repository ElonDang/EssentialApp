//
//  HTTPURLResponse+TestHelpers.swift
//  HTTPURLResponse+TestHelpers
//
//  Created by Elon on 25/08/2021.
//

import Foundation

extension HTTPURLResponse {
    convenience init(statusCode: Int) {
        self.init(url: anyURL(), statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
}
