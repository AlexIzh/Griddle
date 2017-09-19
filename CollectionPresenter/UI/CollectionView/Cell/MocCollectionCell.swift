//
//  MocCollectionCell.swift
//  CollectionPresenter
//
//  Created by Ravil Khusainov on 10.02.2016.
//  Copyright © 2016 Moqod. All rights reserved.
//

import Griddle
import UIKit

class MocCollectionCell: CollectionViewCell<String> {

   @IBOutlet weak var titleLabel: UILabel!

   var longPressGesture: UILongPressGestureRecognizer? {
      didSet {
         if let gesture = longPressGesture {
            self.contentView.addGestureRecognizer(gesture)
         }
      }
   }

   override func modelDidChange() {
      titleLabel.text = model
   }

   override class func size(for model: Model, container: UIView) -> CGSize? {
      return CGSize(width: 100, height: 100)
   }
}
