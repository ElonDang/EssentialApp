//
//  FeedCache.swift
//  FeedCache
//
//  Created by Elon on 22/08/2021.
//

import Foundation

public protocol FeedCache {
    typealias Result = Swift.Result<Void, Error>
    func save(_ feed: [FeedImage], completion: @escaping (Result) -> Void)
}
