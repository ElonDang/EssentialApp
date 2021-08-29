//
//  UIButton+TestHelper.swift
//  UIButton+TestHelper
//
//  Created by Elon on 16/08/2021.
//

import UIKit

extension UIButton {
    func simulateButtonTap() {
        simulateAction(.touchUpInside)
    }
}
