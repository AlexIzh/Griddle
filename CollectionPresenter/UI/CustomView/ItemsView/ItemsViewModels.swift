//
//  ItemsViewModels.swift
//  CollectionPresenter
//
//  Created by Alex on 22/03/16.
//  Copyright © 2016 Moqod. All rights reserved.
//

import Foundation
import UIKit
import CollectionPresenterFramework

struct ItemsViewMap : Map {
    let registrationItems: [RegistrationItem] = []
	
	func viewInfo(for model: Any, indexPath: CollectionPresenterFramework.IndexPath) -> ViewInfo? {
		return ViewInfo(identifier: "CellID", viewClass: ItemView.self)
	}
}

class ItemsViewSourceFactory {
    struct Model {
		enum Shape: Int {
			case circle
			case rectangle
		}
		
        var title: String
        var position: CGPoint = CGPoint(x: CGFloat(Float(arc4random()) / Float(UINT32_MAX)), y: CGFloat(Float(arc4random()) / Float(UINT32_MAX)))
		var shape: Shape = .rectangle
		var color: UIColor = Model.randomColor()
		
        init(_ title: String) {
			self.title = title
		}
		
		private static func randomColor() -> UIColor {
			let random: () -> CGFloat = { CGFloat(arc4random() % 255) / 255.0 }
			return UIColor(red: random(), green: random(), blue: random(), alpha: 1)
		}
    }
	
    static func dataSource() -> ArraySource<ItemsViewSourceFactory.Model> {
		return [ Model("1"), Model("2"), Model("3"), Model("4"), Model("5") ]
    }
}

extension ItemsViewSourceFactory.Model: Equatable {}
func ==(lhs: ItemsViewSourceFactory.Model, rhs: ItemsViewSourceFactory.Model) -> Bool {
    return lhs.title == rhs.title
}
