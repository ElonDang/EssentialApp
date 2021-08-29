//
//  UIRefreshControl+TestHelper.swift
//  UIRefreshControl+TestHelper
//
//  Created by Elon on 16/08/2021.
//

import UIKit

extension UIRefreshControl {
    func simulateUserRefresh() {
        simulateAction(.valueChanged)
    }
}
