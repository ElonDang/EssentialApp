//
//  HTTPClient.swift
//  HTTPClient
//
//  Created by Elon on 12/08/2021.
//

import Foundation

public protocol HTTPClientTask {
    func cancel()
}

public protocol HTTPClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>

    func get(from url: URL, completion: @escaping (Result) -> Void) -> HTTPClientTask
}
