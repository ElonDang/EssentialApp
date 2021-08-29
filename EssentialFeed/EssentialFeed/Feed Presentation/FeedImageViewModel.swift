//
//  FeedImageViewModel.swift
//  FeedImageViewModel
//
//  Created by Elon on 19/08/2021.
//

import Foundation

public struct FeedImageViewModel {
    public let description: String?
    public let location: String?

    public var hasLocation: Bool {
        return location != nil
    }
}
