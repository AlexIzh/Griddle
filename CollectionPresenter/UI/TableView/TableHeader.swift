//
//  TableHeader.swift
//  CollectionPresenter
//
//  Created by Alex on 31/03/16.
//  Copyright © 2016 Moqod. All rights reserved.
//

import Foundation
import Griddle
import UIKit

class TableHeader: HeaderFooterView<String> {
   override class func size(for model: String, container: UIView) -> CGSize? { return CGSize(width: 0, height: 40) }

   lazy var label: UILabel = {
      let label = UILabel()
      label.textColor = UIColor.black
      return label
   }()

   override init(reuseIdentifier: String?) {
      super.init(reuseIdentifier: reuseIdentifier)
      addSubview(label)
   }

   required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
   }
   override func layoutSubviews() {
      super.layoutSubviews()
      label.frame = bounds
   }

   override func modelDidChange() {
      super.modelDidChange()
      label.text = model
   }
}
