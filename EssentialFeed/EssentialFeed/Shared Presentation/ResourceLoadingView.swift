//
//  ResourceLoadingView.swift
//  ResourceLoadingView
//
//  Created by Elon on 27/08/2021.
//

import Foundation

public protocol ResourceLoadingView: AnyObject {
    func display(_ viewModel: ResourceLoadingViewModel)
}
