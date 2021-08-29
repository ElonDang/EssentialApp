//
//  LoadResourcePresenter.swift
//  LoadResourcePresenter
//
//  Created by Elon on 27/08/2021.
//

import Foundation

public protocol ResourceView {
    associatedtype ResourceViewModel
    func display(_ viewModel: ResourceViewModel)
}

public final class LoadResourcePresenter<Resource, View: ResourceView> {
    public typealias Mapper = (Resource) throws -> View.ResourceViewModel
    private let errorView: ResourceErrorView
    private let loadingView: ResourceLoadingView
    private let resourceView: View
    private let mapper: Mapper
    
    public static var errorMessage: String {
        return NSLocalizedString("GENERIC_CONNECTION_ERROR",
                                 tableName: "Shared",
                                 bundle: Bundle(for: Self.self),
                                 comment: "Error mesage displayed when we can't load the resource from the server")
    }
    
    public init(resourceView: View,
                loadingView: ResourceLoadingView,
                errorView: ResourceErrorView,
                mapper: @escaping Mapper) {
        self.resourceView = resourceView
        self.loadingView = loadingView
        self.errorView = errorView
        self.mapper = mapper
    }
    
    public func didStartLoading() {
        errorView.display(.noError)
        loadingView.display(.init(isLoading: true))
    }
    
    public func didFinishLoading(with resource: Resource) {
        do {
            resourceView.display(try mapper(resource))
            loadingView.display(ResourceLoadingViewModel(isLoading: false))
        } catch {
            didFinishLoading(with: error)
        }
    }
    
    public func didFinishLoading(with error: Error) {
        loadingView.display(ResourceLoadingViewModel(isLoading: false))
        errorView.display(.errorMessage(Self.errorMessage))
    }

}
