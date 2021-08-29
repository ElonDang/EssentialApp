//
//  FeedViewController+TestHelpers.swift
//  FeedViewController+TestHelpers
//
//  Created by Elon on 16/08/2021.
//

import UIKit
import EssentialFeediOS

extension ListViewController {
    
    @discardableResult
    func simulateFeedImageViewVisible(at row: Int = 0) -> FeedImageCell? {
        return feedImageView(at: row) as? FeedImageCell
    }
    
    @discardableResult
    func simulateFeedImageViewNotVisible(at row: Int = 0) -> FeedImageCell? {
        let view = simulateFeedImageViewVisible(at: row)
        
        let dl = tableView.delegate
        let index = IndexPath(row: row, section: feedSection)
        dl?.tableView?(tableView, didEndDisplaying: view!, forRowAt: index)
        return view
    }
    
    var errorMessage: String? {
        return errorView.message
    }
    
    func simulateTapOnError() {
        return errorView.simulateButtonTap()
    }
    
    func simulateUserInitiatedRefresh() {
        refreshControl?.simulateUserRefresh()
    }
    
    var isShowingLoadingIndicator: Bool {
        refreshControl?.isRefreshing == true
    }
    
    func numberOfRenderedFeedImageViews() -> Int {
        return tableView.numberOfSections == 0 ? 0 : tableView.numberOfRows(inSection: feedSection)
    }
    
    func feedImageView(at row: Int = 0) -> UITableViewCell? {
        let indexPath = IndexPath(row: row, section: feedSection)
        guard numberOfRenderedFeedImageViews() > row, let cell = item(at: indexPath) else {
            return nil
        }
        
        let dl = tableView.delegate
        dl?.tableView?(tableView, willDisplay: cell, forRowAt: indexPath)
        return cell
    }
    
    private func item(at indexPath: IndexPath) -> UITableViewCell? {
        let ds = tableView.dataSource
        return ds?.tableView(tableView, cellForRowAt: indexPath)
    }
    
    func renderedFeedImageData(at index: Int) -> Data? {
        return simulateFeedImageViewVisible(at: index)?.renderedImage
    }
    
    func simulateFeedImageViewNearVisible(at row: Int = 0) {
        let pf = tableView.prefetchDataSource
        let indexPath = IndexPath(row: row, section: feedSection)
        pf?.tableView(tableView, prefetchRowsAt: [indexPath])
    }
    
    func simulateFeedImageViewNotNearVisible(at row: Int = 0) {
        simulateFeedImageViewNearVisible(at: row)
        
        let pf = tableView.prefetchDataSource
        let indexPath = IndexPath(row: row, section: feedSection)
        pf?.tableView?(tableView, cancelPrefetchingForRowsAt: [indexPath])
    }
    
    private var feedSection: Int {
        return 0
    }
}
