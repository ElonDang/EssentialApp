//
//  FeedLoaderPresentationAdapter.swift
//  FeedLoaderPresentationAdapter
//
//  Created by Elon on 18/08/2021.
//

import Foundation
import EssentialFeed
import Combine

final class ResourceLoaderPresentationAdapter<Resource, View: ResourceView> {
    private let loader: () -> AnyPublisher<Resource, Error>
    private var cancellable: AnyCancellable?
    var presenter: LoadResourcePresenter<Resource, View>?
    
    init(loader: @escaping () -> AnyPublisher<Resource, Error>) {
        self.loader = loader
    }
    
    func loadResource() {
        presenter?.didStartLoading()
        
        cancellable = loader()
            .sink {[weak self] completion in
                switch completion {
                case let .failure(error):
                    self?.presenter?.didFinishLoading(with: error)
                default: break
                }
            } receiveValue: {[weak self] resource in
                self?.presenter?.didFinishLoading(with: resource)
            }
    }
}

extension ResourceLoaderPresentationAdapter {
    func cancelImageDataLoad() {
        cancellable?.cancel()
        cancellable = nil
    }
}
