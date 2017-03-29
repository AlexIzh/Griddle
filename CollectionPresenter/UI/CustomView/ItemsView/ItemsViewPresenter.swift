//
//  ItemsViewPresenter.swift
//  CollectionPresenter
//
//  Created by Alex on 22/03/16.
//  Copyright © 2016 Moqod. All rights reserved.
//

import Foundation
import UIKit
import CollectionPresenterFramework

class ItemsViewPresenter<DataSourceModel: DataSource>: Presenter<DataSourceModel> {
    let view: ItemsView
	
	init(_ view: ItemsView, source: DataSourceModel, map: Map) {
        self.view = view
		
		super.init(source: source, map: map)
		
        view.delegate = self
        view.dataSource = self
    }
	
	open override func dataSourceDidRefresh(_ dataSource: DataSourceModel) {
		view.reloadData()
	}

	open override func dataSource(_ dataSource: DataSourceModel, didMoveItemFrom from: CollectionPresenterFramework.IndexPath, to: CollectionPresenterFramework.IndexPath) {
		switch (from, to) {
		case let (.item(_, item), .item(_, toItem)):
			view.moveItem(from: item, to: toItem)
			
		default: break
		}
	}
	open override func dataSource(_ dataSource: DataSourceModel, didDeleteItemAt indexPath: CollectionPresenterFramework.IndexPath) {
		if case let .item(_, index) = indexPath {
			view.deleteItem(at: index)
		}
	}
	open override func dataSource(_ dataSource: DataSourceModel, didInsertItemAt indexPath: CollectionPresenterFramework.IndexPath) {
		if case let .item(_, index) = indexPath {
			view.insertItem(at: index)
		}
	}
	open override func dataSource(_ dataSource: DataSourceModel, didUpdateItemAt indexPath: CollectionPresenterFramework.IndexPath) {
		if case let .item(_, index) = indexPath {
			view.reloadItem(at: index)
		}
	}
}

extension ItemsViewPresenter : ItemsViewDelegate, ItemsViewDataSource {
    func sizeForItem(at index: Int) -> CGSize {
		guard let row = dataSource.item(at: 0, index: index)
			else { return .zero }
		
		let info = map.viewInfo(for: row, indexPath: .item(section: 0, item: index))
		return info?.size(row, view) ?? .zero
    }
	
    func numberOfItems(in view: ItemsView) -> Int {
		return dataSource.itemsCount(for: 0)
    }
	
    func viewForItem(at index: Int) -> ItemView {
		guard let row = dataSource.item(at: 0, index: index), let info = map.viewInfo(for: row, indexPath: .item(section: 0, item: index))
			else { fatalError("DataSource doesn't contains item for index = \(index) or map doesn't contain information for this item.") }
		
		/*
			You can add logic with registration of class and identifier like in UITableView or UICollectionView.
			For simple example I just create hardcoded view.
		*/
        let view = ItemView()
        info.setModel(view, row)
		delegate.didUpdateCell(view, row, (0, index))
        return view
    }
	
    func coordinatesForItem(at index: Int) -> CGPoint {
		guard let row = dataSource.item(at: 0, index: index) as? ItemsViewSourceFactory.Model
			else { fatalError("dataSource doesn't contain item for \(index) or this item with incorrect type.") }
	
        return row.position
    }
	
    func view(_ view: ItemsView, didSelectItemAt index: Int) {
		guard let row = dataSource.item(at: 0, index: index)
			else { return }
		delegate.didSelectCell(view.view(for: index), row, (0, index))
    }
}
