//
//  FeedViewControllerTests+Localization.swift
//  FeedViewControllerTests+Localization
//
//  Created by Elon on 18/08/2021.
//

import XCTest
import EssentialFeed

extension FeedUIIntegrationTests {
    
    var localizedErrorMessage: String {
        return LoadResourcePresenter<Any, DummyView>.errorMessage
    }
    
    var localizedTitle: String {
        return FeedPresenter.title
    }
    
    // MARK: - Helpers
    private class DummyView: ResourceView {
        func display(_ viewModel: Any) {}
    }
    
}
