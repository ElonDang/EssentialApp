//
//  FeedCacheTestsHelper.swift
//  FeedCacheTestsHelper
//
//  Created by Elon on 13/08/2021.
//

import Foundation
import EssentialFeed

func uniqueImage() -> FeedImage {
    FeedImage(id: UUID(), description: "any", location: "any", url: anyURL())
}

func uniqueImageFeed() -> (models: [FeedImage], local: [LocalFeedImage]) {
    let feed = [uniqueImage(), uniqueImage()]
    let local = feed.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
    
    return (feed, local)
}

extension Date {
    private var maxCacheAge: Int {
        return 7
    }
    
    func minusFeedCacheMaxAge() -> Date {
        return adding(days: -maxCacheAge)
    }
}

extension Date {
    func adding(days: Int, calendar: Calendar = Calendar(identifier: .gregorian)) -> Date {
        return calendar.date(byAdding: .day, value: days, to: self)!
    }
    
    func adding(seconds: Int, calendar: Calendar = Calendar(identifier: .gregorian)) -> Date {
        return calendar.date(byAdding: .second, value: seconds, to: self)!
    }
}
