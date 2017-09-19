//
//  ItemView.swift
//  CollectionPresenter
//
//  Created by Ravil Khusainov on 22/03/16.
//  Copyright © 2016 Moqod. All rights reserved.
//

import Griddle
import UIKit

class ItemView: UIControl, ReusableView {
   var contentLabel: UILabel = {
      let label = UILabel()
      label.textColor = .black
      label.textAlignment = .center
      return label
   }()

   var model: ItemsViewSourceFactory.Model! {
      didSet {
         layer.cornerRadius = model.shape == .circle ? 20 : 0
         contentLabel.text = model.title
         backgroundColor = model.color
         setNeedsLayout()
      }
   }

   static func size(for model: Model, container: UIView) -> CGSize? {
      return CGSize(width: 40, height: 40)
   }

   required init() {
      super.init(frame: .zero)
      addSubview(contentLabel)
   }

   required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
   }

   override func layoutSubviews() {
      super.layoutSubviews()
      contentLabel.frame = bounds
   }
}
