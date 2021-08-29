//
//  FeedViewAdapter.swift
//  FeedViewAdapter
//
//  Created by Elon on 18/08/2021.
//

import UIKit
import EssentialFeed
import EssentialFeediOS

final class FeedViewAdapter: ResourceView {
    private weak var controller: ListViewController?
    private let loader: (URL) -> FeedImageDataLoader.Publisher
    
    init(controller: ListViewController, imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher) {
        self.controller = controller
        self.loader = imageLoader
    }
    
    func display(_ viewModel: FeedViewModel) {
        controller?.display(viewModel.feed.map { image in
            let adapter = ResourceLoaderPresentationAdapter<Data, WeakRefVirtualProxy<FeedImageCellController>>(
                loader: { [loader] in
                    loader(image.url)
                })
            
            let cellController = FeedImageCellController(
                viewModel: FeedImagePresenter.map(image),
                loadImageData: adapter.loadResource,
                cancelImageDataLoad: adapter.cancelImageDataLoad)
            
            let feedCellPresenter = LoadResourcePresenter<Data, WeakRefVirtualProxy<FeedImageCellController>>(
                resourceView: WeakRefVirtualProxy(cellController),
                loadingView: WeakRefVirtualProxy(cellController),
                errorView: WeakRefVirtualProxy(cellController),
                mapper: { data in
                    guard let image = UIImage(data: data) else {
                        throw InvalidImageData()
                    }
                    return image
                })
            
            adapter.presenter = feedCellPresenter
            
            return CellController(id: image, cellController)
        })
    }
    
}

private struct InvalidImageData: Error {}
