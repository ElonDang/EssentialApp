//
//  FeedImageDataCache.swift
//  FeedImageDataCache
//
//  Created by Elon on 22/08/2021.
//

import Foundation

public protocol FeedImageDataCache {
    typealias Result = Swift.Result<Void, Error>
    func save(_ data: Data, for url: URL, completion: @escaping (Result) -> Void)
}
