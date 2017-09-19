//
//  IndexPath.swift
//  CollectionPresenter
//
//  Created by Alex on 21/02/16.
//  Copyright © 2016 Moqod. All rights reserved.
//

import Foundation

public enum IndexPath {
   case header(section: Int)
   case footer(section: Int)
   case item(section: Int, item: Int)
}

public extension Griddle.IndexPath {
   public enum FoundationType {
      case table, collection
   }

   public init(_ type: FoundationType, _ path: Foundation.IndexPath) {
      var item: Int

      switch type {
      case .table: item = path.row
      case .collection: item = path.item
      }

      self = .item(section: path.section, item: item)
   }

   public func to(_ type: FoundationType) -> Foundation.IndexPath? {
      if case .item(let section: section, let item: item) = self {
         switch type {
         case .table: return Foundation.IndexPath(row: item, section: section)
         case .collection: return Foundation.IndexPath(item: item, section: section)
         }
      }
      return nil
   }
}

extension Griddle.IndexPath: Equatable {}
public func ==(lhs: Griddle.IndexPath, rhs: Griddle.IndexPath) -> Bool {
   switch (lhs, rhs) {
   case (.header(let section: leftSection), .header(let section: rightSection)):
      return leftSection == rightSection

   case (.footer(let section: leftSection), .footer(let section: rightSection)):
      return leftSection == rightSection

   case (.item(let section: leftSection, let item: leftItem), .item(let section: rightSection, let item: rightItem)):
      return leftSection == rightSection && leftItem == rightItem

   default:
      return false
   }
}
