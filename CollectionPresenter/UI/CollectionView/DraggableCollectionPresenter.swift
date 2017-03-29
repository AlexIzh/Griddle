//
//  DraggableCollectionPresenter.swift
//  Sarah
//
//  Created by Ravil Khusainov on 15/03/16.
//  Copyright © 2016 Moqod. All rights reserved.
//

import UIKit
import CollectionPresenterFramework

protocol DraggableCollectionPresenterDelegate: class {
    func didMoveItem(_ fromIndexPath: CollectionPresenterFramework.IndexPath, toIndexPath: CollectionPresenterFramework.IndexPath)
}

class DraggableCollectionPresenter<DS: DataSource>: CollectionPresenter<DS>, DraggableCollectionViewFlowLayoutDelegate {
    weak var draggableCollectionDelegate: DraggableCollectionPresenterDelegate?
	
	func moveDataItem(_ fromIndexPath: Foundation.IndexPath, toIndexPath: Foundation.IndexPath) {}
	func didFinishMoving(_ fromIndexPath: Foundation.IndexPath, toIndexPath: Foundation.IndexPath) {
		self.draggableCollectionDelegate?.didMoveItem(CollectionPresenterFramework.IndexPath(.collection, fromIndexPath), toIndexPath: CollectionPresenterFramework.IndexPath(.collection, toIndexPath))
	}
}
