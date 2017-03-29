//
//  SegmentViewController.swift
//  CollectionPresenterFramework
//
//  Created by Alex on 14/04/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import CollectionPresenterFramework

struct SegmentMap: Map {
	func viewInfo(for model: Any, indexPath: CollectionPresenterFramework.IndexPath) -> ViewInfo? {
		return ViewInfo(identifier: "Cell", viewClass: MocTableCell.self)
	}
    var registrationItems: [RegistrationItem] = [
        RegistrationItem(viewType: .nib(UINib(nibName: "MocTableCell", bundle: nil)), id: "Cell")
    ]
}

class SegmentViewController: UIViewController {
    @IBOutlet weak var tableView:UITableView!
    
    var presenter: TablePresenter<ArraySource<String>>!
    
    let firstDataSource: ArraySource<String> = [ "First", "Second", "Third" ]
    let secondDataSource: ArraySource<String> = [ "Dog", "Cat", "Pig" ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
		presenter = TablePresenter(tableView, source: firstDataSource, map: SegmentMap())
    }
    
    @IBAction func segmentAction(_ segment:UISegmentedControl) {
        if segment.selectedSegmentIndex == 0 {
            presenter.dataSource = firstDataSource
        } else {
            presenter.dataSource = secondDataSource
        }
    }
}
