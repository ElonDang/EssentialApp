//
//  UIViewController+Snapshot.swift
//  UIViewController+Snapshot
//
//  Created by Elon on 28/08/2021.
//

import UIKit

extension UIViewController {
    func snapshot(for configuration: SnapshotConfiguration) -> UIImage {
        return SnapshotWindow(configuration: configuration, root: self).snapshot()
    }
}
