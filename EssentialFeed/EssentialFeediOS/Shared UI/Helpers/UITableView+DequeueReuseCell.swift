//
//  UITableView+DequeueReuseCell.swift
//  UITableView+DequeueReuseCell
//
//  Created by Elon on 18/08/2021.
//

import UIKit

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>() -> T {
        return dequeueReusableCell(withIdentifier: String(describing: T.self)) as! T
    }
}
