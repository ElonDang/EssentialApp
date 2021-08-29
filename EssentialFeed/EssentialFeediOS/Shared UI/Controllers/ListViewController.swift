//
//  FeedViewController.swift
//  FeedViewController
//
//  Created by Elon on 14/08/2021.
//

import UIKit
import EssentialFeed

public final class ListViewController: UITableViewController, UITableViewDataSourcePrefetching, ResourceLoadingView, ResourceErrorView {
    private(set) public var errorView = ErrorView()
        
    public var onRefresh: (() -> Void)?
    
    private lazy var dataSource: UITableViewDiffableDataSource<Int, CellController> = {
        UITableViewDiffableDataSource(tableView: tableView) { tableView, indexPath, controller in
            controller.dataSource.tableView(tableView, cellForRowAt: indexPath)
        }
    }()
   
    public override func viewDidLoad() {
        super.viewDidLoad()
                
        tableView.dataSource = dataSource
        configureErrorView()
        refresh()
    }
    
    private func configureErrorView() {
        let container = UIView()
        container.backgroundColor = .clear
        
        errorView.onHide = { [weak tableView] in
            tableView?.beginUpdates()
            tableView?.sizeThatHeaderToFit()
            tableView?.endUpdates()
        }
        container.addSubview(errorView)
        errorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            errorView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            errorView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            errorView.topAnchor.constraint(equalTo: container.topAnchor),
            errorView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        ])
        
        tableView.tableHeaderView = container
    }
    
    public func display(_ feed: [CellController]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, CellController>()
        snapshot.appendSections([0])
        snapshot.appendItems(feed, toSection: 0)
        dataSource.apply(snapshot)
    }
    
    @IBAction private func refresh() {
        onRefresh?()
    }
    
    public func display(_ viewModel: ResourceLoadingViewModel) {
        refreshControl?.update(isRefreshing: viewModel.isLoading)
    }
    
    public func display(_ viewModel: ResourceErrorViewModel) {
        errorView.message = viewModel.message
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.sizeThatHeaderToFit()
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let dl = cellController(at: indexPath)?.delegate
        dl?.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            cellController(at: indexPath)?.datasourcePrefetching?.tableView(tableView, prefetchRowsAt: indexPaths)
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let pf = cellController(at: indexPath)?.datasourcePrefetching
            pf?.tableView?(tableView, cancelPrefetchingForRowsAt: [indexPath])
        }
    }
    
    private func cellController(at indexPath: IndexPath) -> CellController? {
        return dataSource.itemIdentifier(for: indexPath)
    }
    
}
