//
//  FeedErrorViewModel.swift
//  FeedErrorViewModel
//
//  Created by Elon on 19/08/2021.
//

import Foundation

public struct ResourceErrorViewModel {
    public let message: String?
    
    public static var noError: ResourceErrorViewModel {
        ResourceErrorViewModel(message: nil)
    }
    
    public static func errorMessage(_ message: String) -> ResourceErrorViewModel {
        ResourceErrorViewModel(message: message)
    }
}
