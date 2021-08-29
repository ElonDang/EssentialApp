//
//  FeedUIComposer.swift
//  FeedUIComposer
//
//  Created by Elon on 16/08/2021.
//

import Foundation
import EssentialFeed
import EssentialFeediOS
import UIKit
import Combine

public final class FeedUIComposer {
    private init() {}
    
    public static func feedComposedWith(feedLoader: @escaping () -> AnyPublisher<[FeedImage], Error>, imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher) -> ListViewController {
        let adapter = ResourceLoaderPresentationAdapter<[FeedImage], FeedViewAdapter>(loader: { feedLoader().dispatchOnMainQueue() })
        
        let feedViewController = FeedUIComposer.makeWith(loadResource: adapter.loadResource,
                                                         title: FeedPresenter.title)
        
        adapter.presenter = LoadResourcePresenter(
            resourceView: FeedViewAdapter(controller: feedViewController,
                                      imageLoader: { imageLoader($0).dispatchOnMainQueue() }),
            loadingView: WeakRefVirtualProxy(feedViewController),
            errorView: WeakRefVirtualProxy(feedViewController),
            mapper: FeedPresenter.map)
        
        return feedViewController
    }
}

private extension FeedUIComposer {
    static func makeWith(loadResource: @escaping () -> Void, title: String) -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedViewController = storyboard.instantiateInitialViewController() as! ListViewController
        feedViewController.onRefresh = loadResource
        feedViewController.title = title
        return feedViewController
    }
}
