//
//  TablePresenter.swift
//  CollectionPresenter
//
//  Created by Alex on 18/02/16.
//  Copyright © 2016 Moqod. All rights reserved.
//

import Foundation
import UIKit
/*
 public protocol TablePresenterDelegate: PresenterDelegate {
 func presenter(_ presenter:Presenter, canMoveCellFromIndexPath fromIndexPath: IndexPath , toIndexPath: IndexPath) -> Bool
 func presenter(_ presenter:Presenter, didMoveCellFromIndexPath fromIndexPath: IndexPath , toIndexPath: IndexPath)
 }

 public extension TablePresenterDelegate {
 func presenter(_ presenter:Presenter, didMoveCellFromIndexPath fromIndexPath: IndexPath , toIndexPath: IndexPath) {}
 func presenter(_ presenter:Presenter, canMoveCellFromIndexPath fromIndexPath: IndexPath , toIndexPath: IndexPath) -> Bool { return true }
 }*/

open class TablePresenter<DataSourceModel: DataSource>: Presenter<DataSourceModel>, UITableViewDataSource, UITableViewDelegate {
   open let tableView: UITableView

   open var insertAnimation: UITableViewRowAnimation = .fade
   open var deleteAnimation: UITableViewRowAnimation = .fade
   open var updateAnimation: UITableViewRowAnimation = .none

   public init(_ tableView: UITableView, source: DataSourceModel, map: Map) {
      self.tableView = tableView

      super.init(source: source, map: map)

      self.tableView.delegate = self
      self.tableView.dataSource = self
   }

   open override func dataSourceDidRefresh(_: DataSourceModel) {
      tableView.reloadData()
   }

   open override func dataSourceDidBeginEditing(_: DataSourceModel) {
      tableView.beginUpdates()
   }

   open override func dataSourceDidEndEditing(_: DataSourceModel) {
      tableView.endUpdates()
   }

   open override func dataSource(_ dataSource: DataSourceModel, didMoveItemFrom from: IndexPath, to: IndexPath) {
      switch (from, to) {
      case (.item(let section, let index), .item(let toSection, let toIndex)):
         tableView.moveRow(at: Foundation.IndexPath(row: index, section: section), to: Foundation.IndexPath(row: toIndex, section: toSection))

      case (.header(let section), .header(let toSection)):
         tableView.reloadSections(IndexSet([section, toSection]), with: updateAnimation)

      case (.footer(let section), .footer(let toSection)):
         tableView.reloadSections(IndexSet([section, toSection]), with: updateAnimation)

      default:
         assertionFailure("IndexPath'es are invalid. (from: \(from), to: \(to))")
      }
   }

   open override func dataSource(_ dataSource: DataSourceModel, didDeleteItemAt indexPath: IndexPath) {
      switch indexPath {
      case .item(let section, let index):
         tableView.deleteRows(at: [Foundation.IndexPath(row: index, section: section)], with: deleteAnimation)

      case .header(let section):
         tableView.reloadSections(IndexSet(integer: section), with: updateAnimation)

      case .footer(let section):
         tableView.reloadSections(IndexSet(integer: section), with: updateAnimation)
      }
   }

   open override func dataSource(_ dataSource: DataSourceModel, didInsertItemAt indexPath: IndexPath) {
      switch indexPath {
      case .item(let section, let index):
         tableView.insertRows(at: [Foundation.IndexPath(row: index, section: section)], with: insertAnimation)

      case .header(let section):
         tableView.reloadSections(IndexSet(integer: section), with: updateAnimation)

      case .footer(let section):
         tableView.reloadSections(IndexSet(integer: section), with: updateAnimation)
      }
   }

   open override func dataSource(_ dataSource: DataSourceModel, didUpdateItemAt indexPath: IndexPath) {
      switch indexPath {
      case .item(let section, let index):
         tableView.reloadRows(at: [Foundation.IndexPath(row: index, section: section)], with: updateAnimation)

      case .header(let section):
         tableView.reloadSections(IndexSet(integer: section), with: updateAnimation)

      case .footer(let section):
         tableView.reloadSections(IndexSet(integer: section), with: updateAnimation)
      }
   }

   open override func dataSource(_ dataSource: DataSourceModel, didMoveSectionFrom from: Int, to: Int) {
      tableView.reloadSections(IndexSet([from, to]), with: updateAnimation)
   }

   open override func dataSource(_ dataSource: DataSourceModel, didDeleteSectionAt index: Int) {
      tableView.reloadSections(IndexSet([index]), with: deleteAnimation)
   }

   open override func dataSource(_ dataSource: DataSourceModel, didInsertSectionAt index: Int) {
      tableView.reloadSections(IndexSet([index]), with: insertAnimation)
   }

   open override func dataSource(_ dataSource: DataSourceModel, didUpdateSectionAt index: Int) {
      tableView.reloadSections(IndexSet([index]), with: updateAnimation)
   }

   // MARK: - Register Reusable Views
   open override func registerReusableViews() {
      super.registerReusableViews()

      for cell in map.registrationItems {
         switch cell.viewType {
         case .nib(let nib):
            if cell.itemType != .row {
               tableView.register(nib, forHeaderFooterViewReuseIdentifier: cell.identifier)
            } else {
               tableView.register(nib, forCellReuseIdentifier: cell.identifier)
            }

         case .viewClass(let cellClass):
            if cell.itemType != .row {
               tableView.register(cellClass, forHeaderFooterViewReuseIdentifier: cell.identifier)
            } else {
               tableView.register(cellClass, forCellReuseIdentifier: cell.identifier)
            }
         }
      }
   }

   // }

   // MARK: - UITableViewDataSource, UITableViewDelegate
   // extension TablePresenter /*: UITableViewDataSource, UITableViewDelegate*/ {
   public func numberOfSections(in tableView: UITableView) -> Int {
      return dataSource.sectionsCount
   }

   public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return dataSource.itemsCount(for: section)
   }

   public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: Foundation.IndexPath) -> CGFloat {
      guard let row = dataSource.item(at: indexPath.section, index: indexPath.row)
      else { return 0 }

      let innerIndexPath = IndexPath(.table, indexPath)
      let info = map.viewInfo(for: row, indexPath: innerIndexPath)
      return info?.estimatedSize(row, tableView)?.height ?? tableView.estimatedRowHeight
   }

   public func tableView(_ tableView: UITableView, heightForRowAt indexPath: Foundation.IndexPath) -> CGFloat {
      guard let row = dataSource.item(at: indexPath.section, index: indexPath.row)
      else { return 0 }

      let innerIndexPath = IndexPath(.table, indexPath)
      let info = map.viewInfo(for: row, indexPath: innerIndexPath)
      return info?.size(row, tableView)?.height ?? tableView.rowHeight
   }

   public func tableView(_ tableView: UITableView, cellForRowAt indexPath: Foundation.IndexPath) -> UITableViewCell {
      guard let row = dataSource.item(at: indexPath.section, index: indexPath.row)
      else { fatalError("DataSource (\(dataSource)) doesn't contain item with indexPath (\(indexPath))") }

      let innerIndexPath = IndexPath(.table, indexPath)
      guard let info = map.viewInfo(for: row, indexPath: innerIndexPath)
      else { fatalError("Map did not return information about view with \(innerIndexPath) for model \(row)") }

      let cell = tableView.dequeueReusableCell(withIdentifier: info.identifier, for: indexPath)
      info.setModel(cell, row)
      delegate.didUpdateCell(cell, row, (indexPath.section, indexPath.row))
      return cell
   }

   public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
      guard let row = dataSource.header(at: section)
      else { return 0 }

      let info = map.viewInfo(for: row, indexPath: .header(section: section))
      return info?.size(row, tableView)?.height ?? tableView.sectionHeaderHeight
   }

   public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
      guard let row = dataSource.footer(at: section)
      else { return 0 }

      let info = map.viewInfo(for: row, indexPath: .footer(section: section))
      return info?.size(row, tableView)?.height ?? tableView.sectionFooterHeight
   }

   public func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
      guard let row = dataSource.footer(at: section)
      else { return 0 }

      let info = map.viewInfo(for: row, indexPath: .footer(section: section))
      return info?.estimatedSize(row, tableView)?.height ?? tableView.estimatedSectionHeaderHeight
   }

   public func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
      guard let row = dataSource.header(at: section)
      else { return 0 }

      let info = map.viewInfo(for: row, indexPath: .header(section: section))
      return info?.estimatedSize(row, tableView)?.height ?? tableView.estimatedSectionFooterHeight
   }

   public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
      guard let row = dataSource.header(at: section), let info = map.viewInfo(for: row, indexPath: .header(section: section))
      else { return nil }

      let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: info.identifier)
      if let view = view {
         info.setModel(view, row)
         delegate.didUpdateHeader(view, row, section)
      }
      return view
   }

   public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
      guard let row = dataSource.footer(at: section), let info = map.viewInfo(for: row, indexPath: .footer(section: section))
      else { return nil }

      let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: info.identifier)
      if let view = view {
         info.setModel(view, row)
         delegate.didUpdateFooter(view, row, section)
      }
      return view
   }

   public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: Foundation.IndexPath) {
      guard let row = dataSource.item(at: indexPath.section, index: indexPath.row)
      else { return }

      if let cell = tableView.cellForRow(at: indexPath) {
         delegate.didSelectCell(cell, row, (indexPath.section, indexPath.row))
      }
   }

   //    public func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: Foundation.IndexPath, to destinationIndexPath: Foundation.IndexPath) {
   //        let source = IndexPath(.table, sourceIndexPath)
   //        let destination = IndexPath(.table, destinationIndexPath)
   //        (self.delegate as? TablePresenterDelegate)?.presenter(self, didMoveCellFromIndexPath: source, toIndexPath: destination)
   //    }
   //
   //    public func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: Foundation.IndexPath, toProposedIndexPath proposedDestinationIndexPath: Foundation.IndexPath) -> Foundation.IndexPath {
   //        guard let canMove = (self.delegate as? TablePresenterDelegate)?.presenter(self, canMoveCellFromIndexPath: IndexPath(.table, sourceIndexPath), toIndexPath: IndexPath(.table, proposedDestinationIndexPath)) else {
   //            return sourceIndexPath
   //        }
   //        guard canMove == true else {
   //            return sourceIndexPath
   //        }
   //        return proposedDestinationIndexPath
   //    }
}
