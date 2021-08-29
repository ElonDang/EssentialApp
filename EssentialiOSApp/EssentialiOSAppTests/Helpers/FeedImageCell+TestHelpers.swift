//
//  FeedImageCell+TestHelpers.swift
//  FeedImageCell+TestHelpers
//
//  Created by Elon on 16/08/2021.
//

import UIKit
import EssentialFeediOS

extension FeedImageCell {
    var isShowingLocation: Bool {
        return !locationContainer.isHidden
    }
    
    var locationText: String? {
        return locationLabel.text
    }
    
    var descriptionText: String? {
        return descriptionLabel.text
    }
    
    var isShowingImageLoadingIndicator: Bool {
        return feedImageContainer.isShimmering
    }
    
    var renderedImage: Data? {
        return feedImageView.image?.pngData()
    }
    
    var isShowingRetryButton: Bool {
        return !retryButton.isHidden
    }
    
    func simulateFeedImageRetryAction() {
        retryButton.simulateButtonTap()
    }
}
