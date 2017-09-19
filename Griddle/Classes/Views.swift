//
//  View.swift
//  CollectionPresenter
//
//  Created by Alex on 21/02/16.
//  Copyright © 2016 Moqod. All rights reserved.
//

import Foundation
import UIKit

public protocol ReusableView {
   associatedtype Model

   var model: Model! { get set }
   static func size(for model: Model, container: UIView) -> CGSize?
   static func estimatedSize(for model: Model, container: UIView) -> CGSize?
}

public extension ReusableView {
   static func size(for model: Model, container: UIView) -> CGSize? { return nil }
   static func estimatedSize(for model: Model, container: UIView) -> CGSize? {
      return size(for: model, container: container)
   }
}

// MARK: - Default classes
/// You can use these classes or create your own
open class TableViewCell<Model>: UITableViewCell, ReusableView {
   open var model: Model! {
      willSet { modelWillUnset() }
      didSet { modelDidChange() }
   }

   open func modelDidChange() {}
   open func modelWillUnset() {}

   // for subclassing
   open class func size(for model: Model, container: UIView) -> CGSize? { return nil }
   open class func estimatedSize(for model: Model, container: UIView) -> CGSize? {
      return size(for: model, container: container)
   }
}

open class HeaderFooterView<Model>: UITableViewHeaderFooterView, ReusableView {
   open var model: Model! {
      willSet { modelWillUnset() }
      didSet { modelDidChange() }
   }

   open func modelDidChange() {}
   open func modelWillUnset() {}

   open class func size(for model: Model, container: UIView) -> CGSize? { return nil }
   open class func estimatedSize(for model: Model, container: UIView) -> CGSize? {
      return size(for: model, container: container)
   }
}

open class CollectionViewCell<Model>: UICollectionViewCell, ReusableView {
   open var model: Model! {
      willSet { modelWillUnset() }
      didSet { modelDidChange() }
   }

   open func modelDidChange() {}
   open func modelWillUnset() {}

   open class func size(for model: Model, container: UIView) -> CGSize? { return nil }
   open class func estimatedSize(for model: Model, container: UIView) -> CGSize? {
      return size(for: model, container: container)
   }
}

open class CollectionViewReusableView<Model>: UICollectionReusableView, ReusableView {
   open var model: Model! {
      willSet { modelWillUnset() }
      didSet { modelDidChange() }
   }

   open func modelDidChange() {}
   open func modelWillUnset() {}

   open class func size(for model: Model, containerView: UIView) -> CGSize? { return nil }
   open class func estimatedSize(for model: Model, containerView: UIView) -> CGSize? {
      return size(for: model, containerView: containerView)
   }
}
