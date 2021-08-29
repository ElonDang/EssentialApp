//
//  FeedImageCellController.swift
//  FeedImageCellController
//
//  Created by Elon on 16/08/2021.
//

import UIKit
import EssentialFeed

public final class FeedImageCellController: NSObject {
    public typealias ResourceViewModel = UIImage
    private var cell: FeedImageCell?
    private let viewModel: FeedImageViewModel
    
    private let loadImageData: () -> Void
    private let cancelImageDataLoad: () -> Void
    
    public init(viewModel: FeedImageViewModel,
                loadImageData: @escaping () -> Void,
                cancelImageDataLoad: @escaping () -> Void) {
        self.loadImageData = loadImageData
        self.cancelImageDataLoad = cancelImageDataLoad
        self.viewModel = viewModel
    }
}

extension FeedImageCellController: UITableViewDataSource, UITableViewDelegate, UITableViewDataSourcePrefetching {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cell = tableView.dequeueReusableCell()
        cell?.locationLabel.text = viewModel.location
        cell?.descriptionLabel.text = viewModel.description
        cell?.locationContainer.isHidden = !viewModel.hasLocation
        cell?.onRetry = {[weak self] in
            self?.loadImageData()
        }
        return cell!
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        loadImageData()
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        loadImageData()
    }
    
    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancel()
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        cancel()
    }
    
    private func cancel() {
        releaseCellForReuse()
        cancelImageDataLoad()
    }
    
    private func releaseCellForReuse() {
        cell = nil
    }

}

extension FeedImageCellController: ResourceView, ResourceErrorView, ResourceLoadingView {
    public func display(_ viewModel: UIImage) {
        cell?.feedImageView.setImageAnimated(viewModel)
    }
    
    public func display(_ viewModel: ResourceErrorViewModel) {
        cell?.retryButton.isHidden = viewModel.message == nil
    }
    
    public func display(_ viewModel: ResourceLoadingViewModel) {
        cell?.feedImageContainer.isShimmering = viewModel.isLoading
    }
}
