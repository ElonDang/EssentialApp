//
//  UIImageView+Animations.swift
//  UIImageView+Animations
//
//  Created by Elon on 18/08/2021.
//

import UIKit

extension UIImageView {
    func setImageAnimated(_ newImage: UIImage?) {
        image = newImage
        
        guard newImage != nil else { return }
        alpha = 0
        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
        }
    }
}
