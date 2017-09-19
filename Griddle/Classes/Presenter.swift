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
      public var didSelectCell: (_ view: UIView, _ model: DataSourceModel.Section.Item, _ path: (section: Int, index: Int)) -> Void = { _ in }
      public var didSelectHeader: (_ view: UIView, _ model: DataSourceModel.Section.Header, _ section: Int) -> Void = { _ in }
      public var didSelectFooter: (_ view: UIView, _ model: DataSourceModel.Section.Footer, _ section: Int) -> Void = { _ in }

      public var didUpdateCell: (_ view: UIView, _ model: DataSourceModel.Section.Item, _ path: (section: Int, index: Int)) -> Void = { _ in }
      public var didUpdateHeader: (_ view: UIView, _ model: DataSourceModel.Section.Header, _ section: Int) -> Void = { _ in }
      public var didUpdateFooter: (_ view: UIView, _ model: DataSourceModel.Section.Footer, _ section: Int) -> Void = { _ in }
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
      dataSource = source
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
         case .row(let info):
            self.didUpdate(with: info)

         case .section(let info):
            self.didUpdate(with: info)
         }
      }
   }

   private func didUpdate(with info: DataSourceDelegate.UpdateInfo.Row) {
      switch info {
      case .delete(let path):
         dataSource(dataSource, didDeleteItemAt: path)

      case .insert(let path):
         dataSource(dataSource, didInsertItemAt: path)

      case .move(let from: fromPath, let to: toPath):
         dataSource(dataSource, didMoveItemFrom: fromPath, to: toPath)

      case .update(let path):
         dataSource(dataSource, didUpdateItemAt: path)
      }
   }

   private func didUpdate(with info: DataSourceDelegate.UpdateInfo.Section) {
      switch info {
      case .delete(let path):
         dataSource(dataSource, didDeleteSectionAt: path)

      case .insert(let path):
         dataSource(dataSource, didInsertSectionAt: path)

      case .move(let from: fromPath, let to: toPath):
         dataSource(dataSource, didMoveSectionFrom: fromPath, to: toPath)

      case .update(let path):
         dataSource(dataSource, didUpdateSectionAt: path)
      }
   }

   //    private override init() {
   //        super.init()
   //    }

   open func registerReusableViews() {}

   open func dataSourceDidRefresh(_: DataSourceModel) {}

   open func dataSourceDidBeginEditing(_: DataSourceModel) {}
   open func dataSourceDidEndEditing(_: DataSourceModel) {}

   open func dataSource(_ dataSource: DataSourceModel, didMoveItemFrom from: IndexPath, to: IndexPath) {}
   open func dataSource(_ dataSource: DataSourceModel, didDeleteItemAt indexPath: IndexPath) {}
   open func dataSource(_ dataSource: DataSourceModel, didInsertItemAt indexPath: IndexPath) {}
   open func dataSource(_ dataSource: DataSourceModel, didUpdateItemAt indexPath: IndexPath) {}

   open func dataSource(_ dataSource: DataSourceModel, didMoveSectionFrom from: Int, to: Int) {}
   open func dataSource(_ dataSource: DataSourceModel, didDeleteSectionAt index: Int) {}
   open func dataSource(_ dataSource: DataSourceModel, didInsertSectionAt index: Int) {}
   open func dataSource(_ dataSource: DataSourceModel, didUpdateSectionAt index: Int) {}
}
