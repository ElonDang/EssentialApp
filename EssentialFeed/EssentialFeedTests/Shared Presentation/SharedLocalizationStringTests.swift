//
//  SharedLocalizationStringTests.swift
//  SharedLocalizationStringTests
//
//  Created by Elon on 27/08/2021.
//

import XCTest
import EssentialFeed

final class SharedLocalizationTests: XCTestCase {
    
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "Shared"
        let presentationBundle = Bundle(for: LoadResourcePresenter<Any, DummyView>.self)
        assertLocalizeKeyAndValuesExist(in: presentationBundle, table)
    }

    // MARK: - Helpers
    private class DummyView: ResourceView {
        func display(_ viewModel: Any) {}
    }
}
