//
//  LoadResourcePresenterTests.swift
//  LoadResourcePresenterTests
//
//  Created by Elon on 27/08/2021.
//

import XCTest
import EssentialFeed

class LoadResourcePresenterTests: XCTestCase {
    
    func test_init_doesNotSendMessagesToView() {
        let (_, viewSpy) = makeSUT()

        XCTAssertTrue(viewSpy.receivedMessages.isEmpty)
    }
    
    func test_didStartLoading_displaysNoErrorMessageAndStartLoading() {
        let (sut, viewSpy) = makeSUT()
        
        sut.didStartLoading()
        
        XCTAssertEqual(viewSpy.receivedMessages, [.error(.none), .load(true)])
    }
    
    func test_didFinishLoading_displaysResourceAndStopLoading() {
        let (sut, viewSpy) = makeSUT(mapper: { resource in
            resource + " view model"
        })
        
        sut.didFinishLoading(with: "resource")
        
        XCTAssertEqual(viewSpy.receivedMessages, [
            .resourceViewModel("resource view model"),
            .load(false)
        ])
    }
    
    func test_didFinishLoading_displaysLocalizedErrorMessgeAndStopLoading() {
        let (sut, viewSpy) = makeSUT()
        
        sut.didFinishLoading(with: anyNSError())
        
        XCTAssertEqual(viewSpy.receivedMessages, [.error(localized("GENERIC_CONNECTION_ERROR")),
                                                    .load(false)])
    }
    
    // MARK: - Helpers
    private typealias SUT = LoadResourcePresenter<String, ResourceViewSpy>
    
    private func makeSUT(
        mapper: @escaping SUT.Mapper = { _ in "Any" },
        file: StaticString = #filePath,
        line: UInt = #line) -> (sut: SUT, viewSpy: ResourceViewSpy) {
            let viewSpy = ResourceViewSpy()
            let sut = SUT(resourceView: viewSpy, loadingView: viewSpy, errorView: viewSpy, mapper: mapper)
            trackMemoryLeaks(sut, file: file, line: line)
            trackMemoryLeaks(viewSpy, file: file, line: line)
            return (sut, viewSpy)
    }
    
    private class ResourceViewSpy: ResourceView, ResourceErrorView, ResourceLoadingView {
        typealias ResourceViewModel = String
        
        enum Message: Hashable {
            case error(String?)
            case load(Bool)
            case resourceViewModel(String)
        }
        
        private(set) var receivedMessages = Set<Message>()
        
        func display(_ viewModel: ResourceErrorViewModel) {
            receivedMessages.insert(.error(viewModel.message))
        }
        
        func display(_ viewModel: ResourceLoadingViewModel) {
            receivedMessages.insert(.load(viewModel.isLoading))
        }
        
        func display(_ viewModel: ResourceViewModel) {
            receivedMessages.insert(.resourceViewModel(viewModel))
        }
    }
    
    private func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
        let table = "Shared"
        let bundle = Bundle(for: SUT.self)
        let localizedTitle = bundle.localizedString(forKey: key, value: nil, table: table)
        if key == localizedTitle {
            XCTFail("Missing localized string for key: \(key)", file: file, line: line)
        }
        
        return localizedTitle
    }
    
}
