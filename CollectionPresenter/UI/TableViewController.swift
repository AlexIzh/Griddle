//
//  TableViewController.swift
//  CollectionPresenter
//
//  Created by Ravil Khusainov on 10.02.2016.
//  Copyright © 2016 Moqod. All rights reserved.
//

import Griddle
import UIKit

extension String: Stringable {
   var rawValue: String? { return self }
}

class TableViewController: UITableViewController {

   var presenter: TablePresenter<DictionarySource<String, String>>!
   lazy var dataSource: DictionarySource<String, String> = [
      "section 0": ["frist", "second", "third"],
      "section 1": ["fourth", "fiveth", "sixth"],
      "section 2": ["11", "12", "13"]
   ]

   override func viewDidLoad() {
      super.viewDidLoad()

      let map = DefaultMap()
      map.registrationItems = [
         RegistrationItem(viewType: .nib(UINib(nibName: "MocTableCell", bundle: nil)), id: "Cell"),
         RegistrationItem(viewType: .viewClass(TableHeader.self), id: "Header", itemType: .header)
      ]
      map.viewInfoGeneration = { _, indexPath in
         if case .item = indexPath {
            return ViewInfo(identifier: "Cell", viewClass: MocTableCell.self)
         } else {
            return ViewInfo(identifier: "Header", viewClass: TableHeader.self)
         }
      }

      presenter = TablePresenter(tableView, source: dataSource, map: map)
      presenter.delegate.didUpdateCell = { [unowned self] cell, _, _ in
         if let cell = cell as? MocTableCell, cell.longPressGesture == nil {
            cell.longPressGesture = (self.tableView as? LPRTableView)?.gestureForCell()
         }
      }
      presenter.delegate.didSelectCell = { [unowned self] _, _, path in
         self.deleteItem(at: path.section, index: path.index)
      }

      (tableView as? LPRTableView)?.longPressReorderDelegate = self
   }

   @IBAction func addAction(_: AnyObject) {
      let alert = UIAlertController(title: "To Section:", message: nil, preferredStyle: .actionSheet)
      for key in dataSource.dictionary.keys {
         alert.addAction(UIAlertAction(title: key, style: .default, handler: { _ in
            self.insertToSection(key)
         }))
      }
      alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
      present(alert, animated: true, completion: nil)
   }

   func deleteItem(at section: Int, index: Int) {
      let alert = UIAlertController(title: "Delete?", message: nil, preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
         self.dataSource.deleteItem(at: section, index: index)
      }))
      alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
      present(alert, animated: true, completion: nil)
   }

   func insertToSection(_ key: String) {
      let alert = UIAlertController(title: "After Item:", message: nil, preferredStyle: .actionSheet)
      let items = dataSource[key] ?? []
      for (index, item) in items.enumerated() {
         alert.addAction(UIAlertAction(title: item, style: .default, handler: { _ in
            self.insertToSection(key, index: index + 1)
         }))
      }
      alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
      present(alert, animated: true, completion: nil)
   }

   func insertToSection(_ key: String, index: Int) {
      let alert = UIAlertController(title: "Enter text", message: nil, preferredStyle: UIAlertControllerStyle.alert)
      alert.addTextField { _ in }
      alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { (_) -> Void in
         guard let text = alert.textFields?.first?.text else { return }
         var items = self.dataSource[key] ?? []
         if index >= items.count {
            items.append(text)
         } else {
            items.insert(text, at: index)
         }
         self.dataSource[key] = items
      }))

      alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
      present(alert, animated: true, completion: nil)
   }
}

extension TableViewController: LPRTableViewDelegate {
   func tableView(_ tableView: UITableView, didMoveCell fromIndexPath: Foundation.IndexPath, toIndexPath: Foundation.IndexPath) {}
}
