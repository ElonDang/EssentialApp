//
//  SceneDelegate.swift
//  EssentialiOSApp
//
//  Created by Elon on 21/08/2021.
//

import UIKit
import EssentialFeed
import EssentialFeediOS
import Combine
import CoreData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
        
    private lazy var httpClient: HTTPClient = {
        URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    }()
    
    private lazy var store: FeedStore & FeedImageDataStore = {
        try! CoreDataFeedStore(storeURL: NSPersistentContainer
                                .defaultDirectoryURL()
                                .appendingPathComponent("feed-store.sqlite"))
    }()
    
    private lazy var localFeedLoader: LocalFeedLoader = {
        LocalFeedLoader(store: store, currentDate: Date.init)
    }()
    
    convenience init(httpClient: HTTPClient, store: FeedStore&FeedImageDataStore) {
        self.init()
        self.httpClient = httpClient
        self.store = store
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: scene)
        configureWindow()
    }
    
    func configureWindow() {
        window?.rootViewController = UINavigationController(rootViewController: FeedUIComposer.feedComposedWith(
            feedLoader: makeRemoteFeedLoaderWithLocalFallback,
            imageLoader: makeImageDataLoaderWithFallback))
        
        window?.makeKeyAndVisible()
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        localFeedLoader.validateCache { _ in }
    }
    
    private func makeRemoteFeedLoaderWithLocalFallback() -> AnyPublisher<[FeedImage], Error> {
        let url = URL(string: "https://static1.squarespace.com/static/5891c5b8d1758ec68ef5dbc2/t/5db4155a4fbade21d17ecd28/1572083034355/essential_app_feed.json")!
        return httpClient
            .loadPublisher(from: url)
            .tryMap(FeedItemsMapper.map)
            .caching(to: localFeedLoader)
            .fallback(to: localFeedLoader.loadPublisher)
            .eraseToAnyPublisher()
    }
    
    private func makeImageDataLoaderWithFallback(for url: URL) -> FeedImageDataLoader.Publisher {
        let localImageDataLoader = LocalFeedImageDataLoader(store: store)
        let remoteImageLoader = RemoteFeedImageDataLoader(client: httpClient)
        
        return localImageDataLoader
            .loadPublisher(from: url)
            .fallback(to: {
                remoteImageLoader
                    .loadPublisher(from: url)
                    .caching(to: localImageDataLoader, for: url)
            })
            .eraseToAnyPublisher()
    }
    
}
