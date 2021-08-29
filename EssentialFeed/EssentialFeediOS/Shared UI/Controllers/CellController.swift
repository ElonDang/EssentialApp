//
//  CellController.swift
//  CellController
//
//  Created by Elon on 28/08/2021.
//

import UIKit

public struct CellController {
    let id: AnyHashable
    public let dataSource: UITableViewDataSource
    let delegate: UITableViewDelegate?
    let datasourcePrefetching: UITableViewDataSourcePrefetching?
    
    public init(id: AnyHashable,  _ delegate: UITableViewDataSource & UITableViewDelegate & UITableViewDataSourcePrefetching ) {
        self.id = id
        self.dataSource = delegate as UITableViewDataSource
        self.delegate = delegate as UITableViewDelegate
        self.datasourcePrefetching = delegate as UITableViewDataSourcePrefetching
    }
    
    public init(id: AnyHashable, dataSource: UITableViewDataSource) {
        self.id = id
        self.dataSource = dataSource
        self.delegate = nil
        self.datasourcePrefetching = nil
    }
}

extension CellController: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
extension CellController: Equatable {
    public static func == (lhs: CellController, rhs: CellController) -> Bool {
        lhs.id == rhs.id
    }
}
