//
//  ImageCommentCellController.swift
//  ImageCommentCellController
//
//  Created by Elon on 28/08/2021.
//

import UIKit
import EssentialFeed

public final class ImageCommentCellController: NSObject, UITableViewDataSource {
    private let model: ImageCommentViewModel
    
    public init(model: ImageCommentViewModel) {
        self.model = model
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ImageCommentCell = tableView.dequeueReusableCell()
        cell.messageLabel.text = model.message
        cell.usernameLabel.text = model.username
        cell.dateLabel.text = model.createdAt
        return cell
    }
}
