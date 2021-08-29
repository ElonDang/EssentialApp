//
//  ImageDataLoaderPresentationAdapter.swift
//  ImageDataLoaderPresentationAdapter
//
//  Created by Elon on 18/08/2021.
//

import UIKit
import EssentialFeed
import Combine

final class ImageDataLoaderPresentationAdapter {
    private let model: FeedImage
    private let imageLoader: (URL) -> FeedImageDataLoader.Publisher
    var presenter: FeedImagePresenter?
    private var cancellable: AnyCancellable?
    
    init(model: FeedImage, imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher) {
        self.model = model
        self.imageLoader = imageLoader
    }
    
}
