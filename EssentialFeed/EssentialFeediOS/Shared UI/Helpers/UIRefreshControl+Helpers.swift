//
//  UIRefreshControl+Helpers.swift
//  UIRefreshControl+Helpers
//
//  Created by Elon on 28/08/2021.
//

import UIKit

extension UIRefreshControl {
    func update(isRefreshing: Bool) {
        isRefreshing ? beginRefreshing() : endRefreshing()
    }
}
