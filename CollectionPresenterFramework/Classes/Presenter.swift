//
//  Presenter.swift
//  CollectionPresenter
//
//  Created by Alex on 21/02/16.
//  Copyright © 2016 Moqod. All rights reserved.
//

import UIKit

open class Presenter<DataSourceModel: DataSource>: NSObject {
	public struct PresenterDelegate {
		public var didSelectCell: (_ view: UIView, _ model: DataSourceModel.Section.Item, _ path: (section: Int, index: Int)) -> Void = {_ in}
		public var didSelectHeader: (_ view: UIView, _ model: DataSourceModel.Section.Header, _ section: Int) -> Void = {_ in}
		public var didSelectFooter: (_ view: UIView, _ model: DataSourceModel.Section.Footer, _ section: Int) -> Void = {_ in}
		
		public var didUpdateCell: (_ view: UIView, _ model: DataSourceModel.Section.Item, _ path: (section: Int, index: Int)) -> Void = {_ in}
		public var didUpdateHeader: (_ view: UIView, _ model: DataSourceModel.Section.Header, _ section: Int) -> Void = {_ in}
		public var didUpdateFooter: (_ view: UIView, _ model: DataSourceModel.Section.Footer, _ section: Int) -> Void = {_ in}
	}
	
    open var delegate = PresenterDelegate()
	
	open var dataSource: DataSourceModel {
		didSet {
			configureSourceDelegate()
			dataSource.delegate.didRefreshAll()
		}
	}
	open var map: Map {
		didSet {
			registerReusableViews()
			dataSource.delegate.didRefreshAll()
		}
	}
	
	public init(source: DataSourceModel, map: Map) {
		self.dataSource = source
		self.map = map
		
		super.init()
		
		configureSourceDelegate()
		registerReusableViews()
	}
	
	deinit {
		dataSource.delegate = DataSourceDelegate()
	}
	
	private func configureSourceDelegate() {
		dataSource.delegate.didRefreshAll = { [unowned self] in
			self.dataSourceDidRefresh(self.dataSource)
		}
		dataSource.delegate.willBeginEditing = { [unowned self] in
			self.dataSourceDidBeginEditing(self.dataSource)
		}
		dataSource.delegate.didEndEditing = { [unowned self] in
			self.dataSourceDidEndEditing(self.dataSource)
		}
		dataSource.delegate.didUpdate = { [unowned self] update in
			switch update {
			case let .row(info):
				self.didUpdate(with: info)
				
			case let .section(info):
				self.didUpdate(with: info)
			}
		}
	}
		
	private func didUpdate(with info: DataSourceDelegate.UpdateInfo.Row) {
		switch info {
		case let .delete(path):
			self.dataSource(self.dataSource, didDeleteItemAt: path)
			
		case let .insert(path):
			self.dataSource(self.dataSource, didInsertItemAt: path)
			
		case let .move(from: fromPath, to: toPath):
			self.dataSource(self.dataSource, didMoveItemFrom: fromPath, to: toPath)
			
		case let .update(path):
			self.dataSource(self.dataSource, didUpdateItemAt: path)
		}
	}
	
	private func didUpdate(with info: DataSourceDelegate.UpdateInfo.Section) {
		switch info {
		case let .delete(path):
			self.dataSource(self.dataSource, didDeleteSectionAt: path)
			
		case let .insert(path):
			self.dataSource(self.dataSource, didInsertSectionAt: path)
			
		case let .move(from: fromPath, to: toPath):
			self.dataSource(self.dataSource, didMoveSectionFrom: fromPath, to: toPath)
			
		case let .update(path):
			self.dataSource(self.dataSource, didUpdateSectionAt: path)
		}
	}
	
//    private override init() {
//        super.init()
//    }
	
    open func registerReusableViews() {}
	
	open func dataSourceDidRefresh(_ dataSource: DataSourceModel) {}
	
	open func dataSourceDidBeginEditing(_ dataSource: DataSourceModel) {}
	open func dataSourceDidEndEditing(_ dataSource: DataSourceModel) {}
	
	open func dataSource(_ dataSource: DataSourceModel, didMoveItemFrom from: IndexPath, to: IndexPath) {}
	open func dataSource(_ dataSource: DataSourceModel, didDeleteItemAt indexPath: IndexPath) {}
	open func dataSource(_ dataSource: DataSourceModel, didInsertItemAt indexPath: IndexPath) {}
	open func dataSource(_ dataSource: DataSourceModel, didUpdateItemAt indexPath: IndexPath) {}
	
	open func dataSource(_ dataSource: DataSourceModel, didMoveSectionFrom from: Int, to: Int) {}
	open func dataSource(_ dataSource: DataSourceModel, didDeleteSectionAt index: Int) {}
	open func dataSource(_ dataSource: DataSourceModel, didInsertSectionAt index: Int) {}
	open func dataSource(_ dataSource: DataSourceModel, didUpdateSectionAt index: Int) {}
}
