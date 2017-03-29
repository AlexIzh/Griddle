//
//  CustomViewController.swift
//  CollectionPresenter
//
//  Created by Ravil Khusainov on 21/03/16.
//  Copyright © 2016 Moqod. All rights reserved.
//

import UIKit
import CollectionPresenterFramework

class CustomViewController: UIViewController {
    
    @IBOutlet var contentView: ItemsView!
	
	var presenter: ItemsViewPresenter<ArraySource<ItemsViewSourceFactory.Model>>!
	var selected: (Int, ItemsViewSourceFactory.Model)?
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		presenter = ItemsViewPresenter(contentView, source: ItemsViewSourceFactory.dataSource(), map: ItemsViewMap())
		presenter.delegate.didSelectCell = { [unowned self] _, aModel, path in
			self.selected?.1.shape = .rectangle
			
			var model = aModel
			model.shape = model.shape == .circle ? .rectangle : .circle
			
			if let selected = self.selected {
				self.presenter.dataSource.perform(actions: [
					.replace(index: selected.0, newModel: selected.1),
					.replace(index: path.index, newModel: model)
					])
			} else {
				self.presenter.dataSource.perform(actions: [ .replace(index: path.index, newModel: model) ])
			}
			self.selected = (path.index, model)
		}
		
		contentView.reloadData()
    }
}
