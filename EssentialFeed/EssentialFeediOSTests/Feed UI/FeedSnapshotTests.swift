//
//  FeedSnapshotTests.swift
//  FeedSnapshotTests
//
//  Created by Elon on 23/08/2021.
//

import XCTest
import EssentialFeediOS
@testable import EssentialFeed

class FeedSnapshotTests: XCTestCase {
        
    func test_feedWithContent() {
        let sut = makeSUT()
        
        sut.display(feedWithContent())
        
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "FEED_WITH_CONTENT_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "FEED_WITH_CONTENT_DARK")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark, contentSize: .extraExtraExtraLarge)), named: "FEED_WITH_CONTENT_DARK_extraExtraExtraLarge")
    }
    
    func test_feedWithFailedImageLoading() {
        let sut = makeSUT()
        
        sut.display(feedWithFailedImageLoading())
        
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "FEED_WITH_FAILED_IMAGE_LOADING_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "FEED_WITH_FAILED_IMAGE_LOADING_DARK")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark, contentSize: .extraExtraExtraLarge)), named: "FEED_WITH_FAILED_IMAGE_LOADING_DARK_extraExtraExtraLarge")
    }

    // MARK: - Helpers
    private func makeSUT() -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let controller = storyboard.instantiateInitialViewController() as! ListViewController
        controller.loadViewIfNeeded()
        return controller
    }
    
    var controllers = [CellController]()
    private func feedWithContent() -> [CellController] {
        let feedCellControllers = [
            FeedImageCellController(
                viewModel: viewModel(description: "The East Side Gallery is an open-air gallery in Berlin. It consists of a series of murals painted directly on a 1,316 m long remnant of the Berlin Wall, located near the centre of Berlin, on Mühlenstraße in Friedrichshain-Kreuzberg. The gallery has official status as a Denkmal, or heritage-protected landmark.",
                                     location: "East Side Gallery\nMemorial in Berlin, Germany"),
                loadImageData: {[weak self] in self?.loadImageDataFake(at: 0)}, cancelImageDataLoad: {}),
            FeedImageCellController(
                viewModel: viewModel(
                    description: "Garth Pier is a Grade II listed structure in Bangor, Gwynedd, North Wales.",
                    location: "Garth Pier"
                ),
                loadImageData: {[weak self] in self?.loadImageDataFake(at: 1)}, cancelImageDataLoad: {})
        ]
        
        controllers = feedCellControllers.map { CellController(id: UUID(), $0) }

        return controllers
    }
    
    private func feedWithFailedImageLoading() -> [CellController] {
        let feedCellControllers = [
            FeedImageCellController(
                viewModel: viewModel(
                    description: nil,
                    location: "a location"
                ),
                loadImageData: {[weak self] in self?.loadImageDataFailFake(at: 0)}, cancelImageDataLoad: {}),
            FeedImageCellController(
                viewModel: viewModel(
                    description: "Garth Pier is a Grade II listed structure in Bangor, Gwynedd, North Wales.",
                    location: nil
                ),
                loadImageData: {[weak self] in self?.loadImageDataFailFake(at: 1)}, cancelImageDataLoad: {})
        ]
        
        controllers = feedCellControllers.map { CellController(id: UUID(), $0) }
        
        return controllers
    }
    
    private func viewModel(description: String? = "any", location: String? = "any") -> FeedImageViewModel {
        FeedImageViewModel(description: description, location: location)
    }
    
    private func loadImageDataFake(at index: Int) {
        let images = [
            UIImage.make(withColor: .red),
            UIImage.make(withColor: .green)
        ]
        (controllers[index].dataSource as! FeedImageCellController).display(.init(isLoading: false))
        (controllers[index].dataSource as! FeedImageCellController).display(images[index])
        (controllers[index].dataSource as! FeedImageCellController).display(.noError)
    }
    
    private func loadImageDataFailFake(at index: Int) {
        (controllers[index].dataSource as! FeedImageCellController).display(.init(isLoading: false))
        (controllers[index].dataSource as! FeedImageCellController).display(.errorMessage("failed"))
    }
        
}
