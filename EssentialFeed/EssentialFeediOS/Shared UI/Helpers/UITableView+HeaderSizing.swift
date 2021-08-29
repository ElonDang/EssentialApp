//
//  UITableView+HeaderSizing.swift
//  UITableView+HeaderSizing
//
//  Created by Elon on 23/08/2021.
//

import UIKit

extension UITableView {
    
    func sizeThatHeaderToFit() {
        guard let header = tableHeaderView else { return }
        
        let size = header.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        
        let needsFrameUpdate = header.frame.height != size.height
        if needsFrameUpdate {
            header.frame.size.height = size.height
            tableHeaderView = header
        }
    }
    
}
