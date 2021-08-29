//
//  FeedViewControllerTests.swift
//  FeedViewControllerTests
//
//  Created by Elon on 14/08/2021.
//

import XCTest
import EssentialFeediOS
import EssentialFeed
import EssentialiOSApp

class FeedUIIntegrationTests: XCTestCase {
    
    func test_feedView_hasTitle() {
        let (sut, _) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.title, localizedTitle)
    }
    
    func test_loadFeedActions_requestsFeedFromLoader() {
        let (sut, loader) = makeSUT()
        XCTAssertEqual(loader.loadFeedCallCount, 0)
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadFeedCallCount, 1)
        
        sut.simulateUserInitiatedRefresh()
        XCTAssertEqual(loader.loadFeedCallCount, 2)
        
        sut.simulateUserInitiatedRefresh()
        XCTAssertEqual(loader.loadFeedCallCount, 3)
    }
    
    func test_loadingIndicator_isVisbleWhileLoadingFeed() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.isShowingLoadingIndicator, true)
        
        loader.completeFeedLoading(at: 0)
        XCTAssertEqual(sut.isShowingLoadingIndicator, false)
        
        sut.simulateUserInitiatedRefresh() // this also trigger the view did load to be called
        XCTAssertEqual(sut.isShowingLoadingIndicator, true)
        
        loader.completeFeedLoading(with: anyNSError(), at: 1)
        XCTAssertEqual(sut.isShowingLoadingIndicator, false)
    }
    
    func test_loadFeedCompletion_rendersSuccessfullyLoadedFeed() {
        let image0 = makeImage(description: "a description", location: "a location")
        let image1 = makeImage(description: nil, location: nil)
        let image2 = makeImage(description: "another description", location: nil)
        let image3 = makeImage(description: nil, location: "another location")
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        assertThat(sut, isRenderingImage: [])
        
        loader.completeFeedLoading(with: [image0], at: 0)
        assertThat(sut, isRenderingImage: [image0])
        
        sut.simulateUserInitiatedRefresh()
        loader.completeFeedLoading(with: [image0, image1, image2, image3], at: 1)
        assertThat(sut, isRenderingImage: [image0, image1, image2, image3])
    }
    
    func test_loadFeedCompletion_rendersSuccessfullyLoadedEmptyFeedAfterNonEmptyFeed() {
        let image0 = makeImage()
        let image1 = makeImage()
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0, image1], at: 0)
        assertThat(sut, isRenderingImage: [image0, image1])
        
        sut.simulateUserInitiatedRefresh()
        loader.completeFeedLoading(with: [], at: 1)
        assertThat(sut, isRenderingImage: [])
    }
    
    func test_loadFeedCompletion_doesNotAlterCurrentRenderingStateOnError() {
        let image0 = makeImage()
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()

        loader.completeFeedLoading(with: [image0], at: 0)
        assertThat(sut, isRenderingImage: [image0])
        
        sut.simulateUserInitiatedRefresh()
        loader.completeFeedLoading(with: anyNSError())
        assertThat(sut, isRenderingImage: [image0])
    }
    
    func test_errorView_rendersErrorMessageUntilNextReload() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertNil(sut.errorMessage)
        
        loader.completeFeedLoading(with: anyNSError())
        XCTAssertEqual(sut.errorMessage, localizedErrorMessage)
        
        sut.simulateUserInitiatedRefresh()
        XCTAssertNil(sut.errorMessage)
    }
    
    func test_errorView_hidesErrorMessageOnTap() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: anyNSError())
        sut.simulateTapOnError()
        
        XCTAssertNil(sut.errorMessage)
    }
    
    func test_feedImageView_loadsImageURLWhenVisible() {
        let image0 = makeImage(url: URL(string: "https://url-1.com/")!)
        let image1 = makeImage(url: URL(string: "https://url-1.com/")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0, image1], at: 0)
        
        XCTAssertEqual(loader.loadedImageURLs, [])
        
        sut.simulateFeedImageViewVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url])
        
        sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url])
    }
    
    func test_feedImageView_cancelsImageLoadingWhenNotVisibleAnymore() {
        let image0 = makeImage(url: URL(string: "https://url-1.com/")!)
        let image1 = makeImage(url: URL(string: "https://url-1.com/")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0, image1], at: 0)
        
        XCTAssertEqual(loader.cancelledImageURLs, [])
        
        sut.simulateFeedImageViewNotVisible(at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.url])
        
        sut.simulateFeedImageViewNotVisible(at: 1)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.url, image1.url])
    }
    
    func test_feedImageViewLoadingIndicator_isVisibleWhileLoadingImage() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [makeImage(), makeImage()])
        
        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, true)
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, true)
        
        loader.completeImageLoading(at: 0)
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false)
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, true)

        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false)
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, false)
    }
    
    func test_feedImageView_rendersImageLoadedFromURL() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [makeImage(), makeImage()])
        
        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(view0?.renderedImage, .none)
        XCTAssertEqual(view1?.renderedImage, .none)
        
        let imageData0 = UIImage.make(withColor: .red).pngData()!
        loader.completeImageLoading(with: imageData0, at: 0)
        XCTAssertEqual(view0?.renderedImage, imageData0)
        XCTAssertEqual(view1?.renderedImage, .none)

        let imageData1 = UIImage.make(withColor: .blue).pngData()!
        loader.completeImageLoading(with: imageData1, at: 1)
        XCTAssertEqual(view0?.renderedImage, imageData0)
        XCTAssertEqual(view1?.renderedImage, imageData1)
    }
    
    func test_feedImageViewRetryButton_isVisibleOnImageURLLoadError() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [makeImage(), makeImage()])
        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(view0?.isShowingRetryButton, false)
        XCTAssertEqual(view1?.isShowingRetryButton, false)
        
        let imageData0 = UIImage.make(withColor: .red).pngData()!
        loader.completeImageLoading(with: imageData0, at: 0)
        XCTAssertEqual(view0?.isShowingRetryButton, false)
        XCTAssertEqual(view1?.isShowingRetryButton, false)
        
        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(view0?.isShowingRetryButton, false)
        XCTAssertEqual(view1?.isShowingRetryButton, true)
    }
    
    func test_feedImageViewRetryAction_retriesLoadFromURL() {
        let image0 = makeImage(url: URL(string: "https://url-1.com/")!)
        let image1 = makeImage(url: URL(string: "https://url-1.com/")!)
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0, image1])
        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url])
        
        loader.completeImageLoadingWithError(at: 0)
        loader.completeImageLoadingWithError(at: 1)

        view0?.simulateFeedImageRetryAction()
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url, image0.url])
        
        view1?.simulateFeedImageRetryAction()
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url, image0.url, image1.url])
    }
    
    func test_feedImageView_preloadsImageURLWhenNearVisible() {
        let image0 = makeImage(url: URL(string: "https://url-1.com/")!)
        let image1 = makeImage(url: URL(string: "https://url-1.com/")!)
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0, image1])
        XCTAssertEqual(loader.loadedImageURLs, [], "Expected no image URL requests until image is near visible")
        
        sut.simulateFeedImageViewNearVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url])

        sut.simulateFeedImageViewNearVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url])
    }
    
    func test_feedImageView_cancelsPreloadImageURLWhenNotNearVisibleAnymore() {
        let image0 = makeImage(url: URL(string: "https://url-1.com/")!)
        let image1 = makeImage(url: URL(string: "https://url-1.com/")!)
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0, image1])
        XCTAssertEqual(loader.cancelledImageURLs, [])
        
        sut.simulateFeedImageViewNotNearVisible(at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.url])

        sut.simulateFeedImageViewNotNearVisible(at: 1)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.url, image1.url])
    }
    
    func test_feedImageView_doesNotRenderLoadedImageWhenNotVisible() { // test that we released the cell holded by the cell controller when the cell is not visible anymore
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [makeImage()])
        
        let view = sut.simulateFeedImageViewNotVisible(at: 0)
        loader.completeImageLoading(with: UIImage.make(withColor: .red).pngData()!, at: 0)
        
        XCTAssertNil(view?.renderedImage)
    }
    
    func test_loadFeedCompletion_dispatchesFromBackgrounToMainThread() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        
        let exp = expectation(description: "wait for completion")
        DispatchQueue.global().async {
            loader.completeFeedLoading(at: 0)
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_loadImageDataCompletion_dispatchesFromBackgrounToMainThread() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [makeImage()])
        sut.simulateFeedImageViewVisible()
        
        let exp = expectation(description: "wait for completion")
        DispatchQueue.global().async {
            loader.completeImageLoading(with: UIImage.make(withColor: .red).pngData()!, at: 0)
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: ListViewController, loader: FeedLoaderSpy) {
        let loader = FeedLoaderSpy()
        let sut = FeedUIComposer.feedComposedWith(feedLoader: loader.loadPublisher, imageLoader: loader.loadPublisher)
        trackMemoryLeaks(sut, file: file, line: line)
        trackMemoryLeaks(loader, file: file, line: line)
        
        return (sut, loader)
    }
    
    func anyNSError() -> NSError {
        NSError(domain: "test", code: 0, userInfo: nil)
    }
    
    private func makeImage(description: String? = "any", location: String? = "any", url: URL = URL(string: "https://any-url")!) -> FeedImage {
        FeedImage(id: UUID(), description: description, location: location, url: url)
    }
    
    private func assertThat(_ sut: ListViewController, isRenderingImage feed: [FeedImage], file: StaticString = #filePath, line: UInt = #line) {
        sut.tableView.layoutIfNeeded()
//        RunLoop.main.run(until: Date())
        guard sut.numberOfRenderedFeedImageViews() == feed.count else {
            return XCTFail("Expected \(sut.numberOfRenderedFeedImageViews()) views rendering but got \(feed.count) views instead", file: file, line: line)
        }
        
        feed.enumerated().forEach { index, image in
            guard let view = sut.feedImageView(at: index) as? FeedImageCell else {
                return XCTFail("Expected FeedImageCell but got \(String(describing: sut.feedImageView(at: index))) instead")
            }
            
            assertThat(view, isConfiguringWith: image, file: file, line: line)
        }
        
//        executeRunLoopToCleanUpReferences()
    }
    
    private func assertThat(_ view: FeedImageCell, isConfiguringWith image: FeedImage, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(view.isShowingLocation, image.location != nil, file: file, line: line)
        XCTAssertEqual(view.locationText, image.location, file: file, line: line)
        XCTAssertEqual(view.descriptionText, image.description, file: file, line: line)
    }
    
    private func executeRunLoopToCleanUpReferences() {
        RunLoop.current.run(until: Date())
    }
}
