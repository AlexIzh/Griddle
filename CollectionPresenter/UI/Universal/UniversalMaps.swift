//
//  UniversalMaps.swift
//  CollectionPresenter
//
//  Created by Alex on 31/03/16.
//  Copyright © 2016 Moqod. All rights reserved.
//

import Foundation
import Griddle
import UIKit

class PadMap: Map {
   func viewInfo(for model: Any, indexPath: Griddle.IndexPath) -> ViewInfo? {
      return ViewInfo(identifier: "Cell", viewClass: MocCollectionCell.self)
   }

   var registrationItems: [RegistrationItem] = [
      RegistrationItem(viewType: .nib(UINib(nibName: "MocCollectionCell", bundle: nil)), id: "Cell")
   ]
}

class PhoneMap: Map {
   func viewInfo(for model: Any, indexPath: Griddle.IndexPath) -> ViewInfo? {
      return ViewInfo(identifier: "Cell", viewClass: MocTableCell.self)
   }

   var registrationItems: [RegistrationItem] = [
      RegistrationItem(viewType: .nib(UINib(nibName: "MocTableCell", bundle: nil)), id: "Cell")
   ]
}
