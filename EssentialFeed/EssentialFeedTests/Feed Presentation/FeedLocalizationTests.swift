//
//  FeedLocalizationTests.swift
//  FeedLocalizationTests
//
//  Created by Elon on 18/08/2021.
//

import XCTest
import EssentialFeed

final class FeedLocalizationTests: XCTestCase {

    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "Feed"
        let presentationBundle = Bundle(for: FeedPresenter.self)
        assertLocalizeKeyAndValuesExist(in: presentationBundle, table)
    }
    
}
