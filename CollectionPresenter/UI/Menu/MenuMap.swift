//
//  MenuMap.swift
//  CollectionPresenter
//
//  Created by Ravil Khusainov on 22/03/16.
//  Copyright © 2016 Moqod. All rights reserved.
//

import UIKit
import CollectionPresenterFramework

struct MenuCellModel: Stringable {
    var title: String
    var segueID: String
	
	var rawValue: String? { return title }
}

class MenuMap: Map {
	
	func viewInfo(for model: Any, indexPath: CollectionPresenterFramework.IndexPath) -> ViewInfo? {
		return ViewInfo(identifier: "Cell", viewClass: MocTableCell.self)
	}
	
    var registrationItems: [RegistrationItem] = [
		RegistrationItem(viewType: .nib(UINib(nibName: "MocTableCell", bundle: nil)), id: "Cell")
    ]
}
