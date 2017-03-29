//
//  DraggableCollectionPresenter.swift
//  Sarah
//
//  Created by Ravil Khusainov on 15/03/16.
//  Copyright © 2016 Moqod. All rights reserved.
//

import UIKit
import Griddle

protocol DraggableCollectionPresenterDelegate: class {
    func didMoveItem(_ fromIndexPath: Griddle.IndexPath, toIndexPath: Griddle.IndexPath)
}

class DraggableCollectionPresenter<DS: DataSource>: CollectionPresenter<DS>, DraggableCollectionViewFlowLayoutDelegate {
    weak var draggableCollectionDelegate: DraggableCollectionPresenterDelegate?
	
	func moveDataItem(_ fromIndexPath: Foundation.IndexPath, toIndexPath: Foundation.IndexPath) {}
	func didFinishMoving(_ fromIndexPath: Foundation.IndexPath, toIndexPath: Foundation.IndexPath) {
		self.draggableCollectionDelegate?.didMoveItem(Griddle.IndexPath(.collection, fromIndexPath), toIndexPath: Griddle.IndexPath(.collection, toIndexPath))
	}
}
