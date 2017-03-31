//
//  CollectionPresenter.swift
//  CollectionPresenter
//
//  Created by Ravil Khusainov on 29.01.2016.
//  Copyright © 2016 Moqod. All rights reserved.
//

import UIKit

open class CollectionPresenter<DataSourceModel: DataSource>: Presenter<DataSourceModel>, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    open let collectionView: UICollectionView
	
	fileprivate var updatingMode: Bool = false
	fileprivate var closures: [ () -> Void ] = []
	
	public init(_ collectionView: UICollectionView, source: DataSourceModel, map: Map) {
		self.collectionView = collectionView
		
		super.init(source: source, map: map)
		
		self.collectionView.delegate = self
		self.collectionView.dataSource = self
	}
    
    //MARK: - CollectionInteractorDelegate
	override open func dataSourceDidRefresh(_ dataSource: DataSourceModel) {
		collectionView.reloadData()
	}
    override open func dataSourceDidBeginEditing(_ dataSource: DataSourceModel) {
        updatingMode = true
    }
    override open func dataSourceDidEndEditing(_ dataSource: DataSourceModel) {
        updatingMode = false
        collectionView.performBatchUpdates({
			self.closures.forEach { $0() }
		}, completion: { _ in
			self.closures = []
		})
    }
	
	func callActionIfNeeded(_ action: @escaping () -> Void) {
		if updatingMode {
			closures.append(action)
		} else {
			action()
		}
	}
	
	open override func dataSource(_ dataSource: DataSourceModel, didMoveItemFrom from: IndexPath, to: IndexPath) {
		let action = { [unowned self] in
			switch (from, to) {
			case let (.item(section, index), .item(toSection, toIndex)):
				self.collectionView.moveItem(at: Foundation.IndexPath(item: index, section: section), to: Foundation.IndexPath(item: toIndex, section: toSection))
				
			case let (.header(section), .header(toSection)):
				self.collectionView.reloadSections(IndexSet([section, toSection]))
				
			case let (.footer(section), .footer(toSection)):
				self.collectionView.reloadSections(IndexSet([section, toSection]))
				
			default:
				assertionFailure("IndexPath'es are invalid. (from: \(from), to: \(to))")
			}
		}
		
		callActionIfNeeded(action)
	}
	
	open override func dataSource(_ dataSource: DataSourceModel, didDeleteItemAt indexPath: IndexPath) {
		let action = { [unowned self] in
			switch indexPath {
			case let .item(section, index):
				self.collectionView.deleteItems(at: [Foundation.IndexPath(item: index, section: section)])
				
			case let .header(section):
				self.collectionView.reloadSections(IndexSet(integer: section))
				
			case let .footer(section):
				self.collectionView.reloadSections(IndexSet(integer: section))
			}
		}
		
		callActionIfNeeded(action)
	}
	
	open override func dataSource(_ dataSource: DataSourceModel, didInsertItemAt indexPath: IndexPath) {
		let action = { [unowned self] in
			switch indexPath {
			case let .item(section, index):
				self.collectionView.insertItems(at: [Foundation.IndexPath(item: index, section: section)])
				
			case let .header(section):
				self.collectionView.reloadSections(IndexSet(integer: section))
				
			case let .footer(section):
				self.collectionView.reloadSections(IndexSet(integer: section))
			}
		}
		
		callActionIfNeeded(action)
	}
	open override func dataSource(_ dataSource: DataSourceModel, didUpdateItemAt indexPath: IndexPath) {
		let action = { [unowned self] in
			switch indexPath {
			case let .item(section, index):
				self.collectionView.reloadItems(at: [Foundation.IndexPath(item: index, section: section)])
				
			case let .header(section):
				self.collectionView.reloadSections(IndexSet(integer: section))
				
			case let .footer(section):
				self.collectionView.reloadSections(IndexSet(integer: section))
			}
		}
		
		callActionIfNeeded(action)
	}
	
	open override func dataSource(_ dataSource: DataSourceModel, didMoveSectionFrom from: Int, to: Int) {
		let action = { [unowned self] in
			self.collectionView.moveSection(from, toSection: to)
		}
		callActionIfNeeded(action)
	}
	open override func dataSource(_ dataSource: DataSourceModel, didDeleteSectionAt index: Int) {
		let action = { [unowned self] in
			self.collectionView.deleteSections(IndexSet(integer: index))
		}
		callActionIfNeeded(action)
	}
	open override func dataSource(_ dataSource: DataSourceModel, didInsertSectionAt index: Int) {
		let action = { [unowned self] in
			self.collectionView.insertSections(IndexSet(integer: index))
		}
		callActionIfNeeded(action)
	}
	open override func dataSource(_ dataSource: DataSourceModel, didUpdateSectionAt index: Int) {
		let action = { [unowned self] in
			self.collectionView.reloadSections(IndexSet(integer: index))
		}
		callActionIfNeeded(action)
	}
	
	// MARK: - Register Reusable Views
	override open  func registerReusableViews() {
		super.registerReusableViews()
		
		for cell in map.registrationItems {
			switch cell.viewType {
			case let .nib(nib):
				if cell.itemType != .row {
					let kind = cell.itemType == .header ? UICollectionElementKindSectionHeader : UICollectionElementKindSectionFooter
					self.collectionView.register(nib, forSupplementaryViewOfKind: kind, withReuseIdentifier: cell.identifier)
				} else {
					self.collectionView.register(nib, forCellWithReuseIdentifier: cell.identifier)
				}
				
			case let .viewClass(cellClass):
				if cell.itemType != .row {
					let kind = cell.itemType == .header ? UICollectionElementKindSectionHeader : UICollectionElementKindSectionFooter
					self.collectionView.register(cellClass, forSupplementaryViewOfKind: kind, withReuseIdentifier: cell.identifier)
				} else {
					self.collectionView.register(cellClass, forCellWithReuseIdentifier: cell.identifier)
				}
			}
		}
	}
//}

// MARK: - UITableViewDataSource, UITableViewDelegate
//extension CollectionPresenter : UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: Foundation.IndexPath) -> CGSize {
		guard let row = dataSource.item(at: indexPath.section, index: indexPath.item)
			else { return .zero }
		
        let innerIndexPath = IndexPath(.collection, indexPath)
		let info = map.viewInfo(for: row, indexPath: innerIndexPath)
		
		let defaultSize = (collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize ?? .zero
        return info?.size(row, collectionView) ?? defaultSize
    }
	
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
		guard let header = dataSource.header(at: section)
			else { return .zero }
		
		let innerIndexPath = IndexPath.header(section: section)
		let info = map.viewInfo(for: header, indexPath: innerIndexPath)
		
        let defaultSize = (collectionViewLayout as? UICollectionViewFlowLayout)?.headerReferenceSize ?? .zero
        return info?.size(header, collectionView) ?? defaultSize
    }
	
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
		guard let footer = dataSource.footer(at: section)
			else { return .zero }
		
		let innerIndexPath = IndexPath.footer(section: section)
		let info = map.viewInfo(for: footer, indexPath: innerIndexPath)
		
		let defaultSize = (collectionViewLayout as? UICollectionViewFlowLayout)?.footerReferenceSize ?? .zero
		return info?.size(footer, collectionView) ?? defaultSize
    }
	
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSource.sectionsCount
    }
	
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.itemsCount(for: section)
    }
	
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: Foundation.IndexPath) -> UICollectionViewCell {
		guard let row = dataSource.item(at: indexPath.section, index: indexPath.item)
			else { fatalError("DataSource (\(dataSource)) doesn't contain item with indexPath (\(indexPath))") }
		
		let innerIndexPath = IndexPath(.table, indexPath)
		guard let info = map.viewInfo(for: row, indexPath: innerIndexPath)
			else { fatalError("Map did not return information about view with \(innerIndexPath) for model \(row)") }
		
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: info.identifier, for: indexPath)
		info.setModel(cell, row)
		delegate.didUpdateCell(cell, row, (indexPath.section, indexPath.item))
        return cell
    }
	
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: Foundation.IndexPath) {
		guard let row = dataSource.item(at: indexPath.section, index: indexPath.item)
			else { return }
		
        if let cell = collectionView.cellForItem(at: indexPath) {
			delegate.didSelectCell(cell, row, (indexPath.section, indexPath.item))
        }
    }
	
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: Foundation.IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
			return headerView(for: indexPath)
        } else {
			return footerView(for: indexPath)
        }
    }
	
	func headerView(for indexPath: Foundation.IndexPath) -> UICollectionReusableView {
		let section = indexPath.section
		guard let header = dataSource.header(at: section)
			else { fatalError("DataSource (\(dataSource)) doesn't contain header for section (\(section))") }
		guard let info = map.viewInfo(for: header, indexPath: .header(section: section))
			else { fatalError("Map did not return information about header for section \(section) for model \(header)") }
		
		let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: info.identifier, for: indexPath)
		info.setModel(view, header)
		delegate.didUpdateHeader(view, header, section)
		return view
	}
	
	func footerView(for indexPath: Foundation.IndexPath) -> UICollectionReusableView {
		let section = indexPath.section
		guard let footer = dataSource.footer(at: section)
			else { fatalError("DataSource (\(dataSource)) doesn't contain footer for section (\(section))") }
		guard let info = map.viewInfo(for: footer, indexPath: .footer(section: section))
			else { fatalError("Map did not return information about footer for section \(section) for model \(footer)") }
		
		let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: info.identifier, for: indexPath)
		info.setModel(view, footer)
		delegate.didUpdateFooter(view, footer, section)
		return view
	}
}
