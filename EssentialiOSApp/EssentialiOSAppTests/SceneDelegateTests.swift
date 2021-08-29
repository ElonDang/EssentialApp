//
//  SceneDelegateTests.swift
//  SceneDelegateTests
//
//  Created by Elon on 23/08/2021.
//

import XCTest
@testable import EssentialiOSApp
import EssentialFeediOS

class SceneDelegateTests: XCTestCase {
    
    func test_configureWindow_setsWindowAsKeyAndVisible() {
        let window = UIWindow()
        let sut = SceneDelegate()
        sut.window = window
        
        sut.configureWindow()
        
//        XCTAssertTrue(window.isKeyWindow)
        XCTAssertFalse(window.isHidden)
    }
    
    func test_configuresWindow_configuresRootViewController() {
        let sut = SceneDelegate()
        sut.window = UIWindow()
        
        sut.configureWindow()
        
        let root = sut.window?.rootViewController
        let rootNavigation = root as? UINavigationController
        let topController = rootNavigation?.viewControllers.first
        
        
        XCTAssertNotNil(rootNavigation)
        XCTAssertTrue(topController is ListViewController)
    }
    
}
