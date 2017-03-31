//
//  Map.swift
//  CollectionPresenter
//
//  Created by Alex on 21/02/16.
//  Copyright © 2016 Moqod. All rights reserved.
//

import Foundation
import UIKit

public struct RegistrationItem {
    public enum ItemType {
        case header, footer, row
    }
    public enum ViewType {
        case nib(UINib)
        case viewClass(AnyClass)
    }
    
    public var identifier: String
    public var itemType: ItemType = .row
    public var viewType: ViewType
    
    public init(viewType: ViewType, id: String, itemType: ItemType = .row) {
        self.viewType = viewType
        self.itemType = itemType
        self.identifier = id
    }
	
    public init(viewClass: AnyClass, itemType: ItemType = .row) {
        self.init(viewType: .viewClass(viewClass), id: String(describing: viewClass), itemType: itemType)
    }
}

public class ViewInfo {
	public var identifier: String
	
	public var setModel: (_ view: Any, _ model: Any) -> Void
	public var size: (_ model: Any, _ container: UIView) -> CGSize?
	public var estimatedSize: (_ model: Any, _ container: UIView) -> CGSize?
	
	public convenience init<T: ReusableView>(viewClass: T.Type) {
		self.init(identifier: String(describing: viewClass.self), viewClass: viewClass)
	}
	
	public init<T: ReusableView>(identifier: String, viewClass: T.Type) {
		self.identifier = identifier
		
		estimatedSize = { aModel, container in
			guard let model = aModel as? T.Model
				else { fatalError("Trying to calculate estimated size with incorrect model \(aModel) for \(String(describing: T.self))") }
			
			return T.estimatedSize(for: model, container: container)
		}
		size = { aModel, container in
			guard let model = aModel as? T.Model
				else { fatalError("Trying to calculate size with incorrect model \(aModel) for \(String(describing: T.self))") }
			
			return T.size(for: model, container: container)
		}
		setModel = { aView, aModel in
			guard let model = aModel as? T.Model
				else { fatalError("\(String(describing: T.self)) doesn't support \(aModel).") }
			guard var view = aView as? T
				else { fatalError("Incorrect view \(aView). \(String(describing: T.self)) is expected...") }
			
			view.model = model
		}
	}
}

public protocol Map {
	func viewInfo(for model: Any, indexPath: IndexPath) -> ViewInfo?
    var registrationItems: [RegistrationItem] { get }
}

public struct DefaultMap: Map {
	public var registrationItems: [RegistrationItem] = []
	
    public var viewInfoGeneration: (Any, IndexPath) -> ViewInfo = { _ in
		fatalError("You should set viewInfoGeneration for DefaultMap object")
    }
	
	public func viewInfo(for model: Any, indexPath: IndexPath) -> ViewInfo? {
		return viewInfoGeneration(model, indexPath)
	}
	
	public init () {}
}
