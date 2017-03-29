//
//  DataSource.swift
//  CollectionPresenter
//
//  Created by Alex on 19/02/16.
//  Copyright © 2016 Moqod. All rights reserved.
//

import Foundation

public protocol DataSection {
	associatedtype Header
	associatedtype Footer
	associatedtype Item
	
	var header: Header? { get }
	var footer: Footer? { get }
	var items: [Item] { get }
}

public struct DataSourceDelegate {
	enum UpdateInfo {
		case section(Section)
		case row(Row)
		
		enum Row {
			case move(from: IndexPath, to: IndexPath)
			case delete(IndexPath)
			case insert(IndexPath)
			case update(IndexPath)
		}
		enum Section {
			case move(from: Int, to: Int)
			case delete(Int)
			case insert(Int)
			case update(Int)
		}
	}
	
	var didRefreshAll: () -> Void = {_ in}
	
	var willBeginEditing: () -> Void = {_ in}
	var didEndEditing: () -> Void = {_ in}
	
	var didUpdate: (UpdateInfo) -> Void = {_ in}
}

public protocol DataSource: class {
	associatedtype Section: DataSection
	
    var delegate: DataSourceDelegate { get set }
	
	var sectionsCount: Int { get }
	
	func item(at section: Int, index: Int) -> Section.Item?
	func header(at section: Int) -> Section.Header?
	func footer(at section: Int) -> Section.Footer?
	
	func itemsCount(for section: Int) -> Int
	
	func sections() -> [Section]
}

//public extension Searchable {//default implementation, works only with classes (search for reference)
//    public func indexPath(for model: Any) -> IndexPath? {
//		let model = model as AnyObject
//        for (index, section) in sections().enumerated() {
//            if let header = section.header as AnyObject?, header === model {
//				return .header(section: index)
//            }
//            if let footer = section.footer as AnyObject?, footer === model {
//				return .footer(section: index)
//            }
//            for (row, item) in section.items.enumerated() {
//				let itemObject = item as AnyObject
//                if itemObject === model {
//					return .item(section: index, item: row)
//                }
//            }
//        }
//        return nil
//    }
//}
