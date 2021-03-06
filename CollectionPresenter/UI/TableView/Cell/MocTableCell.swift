//
//  MocTableCell.swift
//  CollectionPresenter
//
//  Created by Ravil Khusainov on 10.02.2016.
//  Copyright © 2016 Moqod. All rights reserved.
//

import Griddle
import UIKit

protocol Stringable {
   var rawValue: String? { get }
}

class MocTableCell: UITableViewCell, ReusableView {
   typealias Model = Stringable

   @IBOutlet weak var titleLabel: UILabel!

   var model: Stringable! {
      didSet {
         titleLabel.text = model.rawValue
      }
   }

   var longPressGesture: UILongPressGestureRecognizer? {
      didSet {
         if let gesture = longPressGesture {
            contentView.addGestureRecognizer(gesture)
         }
      }
   }

   static func size(for model: Model, container: UIView) -> CGSize? {
      return CGSize(width: container.frame.width, height: 44)
   }

   static func estimatedSize(for model: Model, container: UIView) -> CGSize? {
      return CGSize(width: container.frame.width, height: 44)
   }
}
