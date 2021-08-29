//
//  UIControl+TestHelper.swift
//  UIControl+TestHelper
//
//  Created by Elon on 16/08/2021.
//

import UIKit

extension UIControl {
    
    func simulateAction(_ event: UIControl.Event) {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: event)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
    
}
