//
//  ImageCommentsLocalizationTests.swift
//  ImageCommentsLocalizationTests
//
//  Created by Elon on 27/08/2021.
//

import XCTest
import EssentialFeed

final class ImageCommentsLocalizationTests: XCTestCase {
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "ImageComments"
        let presentationBundle = Bundle(for: ImageCommentsPresenter.self)
        assertLocalizeKeyAndValuesExist(in: presentationBundle, table)
    }

}
