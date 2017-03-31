//
//  MenuViewController.swift
//  CollectionPresenter
//
//  Created by Ravil Khusainov on 22/03/16.
//  Copyright © 2016 Moqod. All rights reserved.
//

import UIKit
import Griddle

class MenuViewController: UITableViewController {

	var presenter: TablePresenter<ArraySource<MenuCellModel>>!
	
	lazy var dataSource: ArraySource<MenuCellModel> = [
		MenuCellModel(title: "Table View", segueID: "Table"),
		MenuCellModel(title: "Collection View", segueID: "Collection"),
		MenuCellModel(title: "iPhone/iPad", segueID: "Universal"),
		MenuCellModel(title: "Custom View", segueID: "Custom"),
		MenuCellModel(title: "One table view, several data sources", segueID: "Segment")
	]
	
    override func viewDidLoad() {
        super.viewDidLoad()

		presenter = TablePresenter(tableView, source: dataSource, map: MenuMap())
		presenter.delegate.didSelectCell = { [unowned self] _, model, _ in
			self.performSegue(withIdentifier: model.segueID, sender: nil)
		}
	}
}
