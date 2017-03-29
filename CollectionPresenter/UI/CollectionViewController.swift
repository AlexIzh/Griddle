//
//  CollectionViewController.swift
//  CollectionPresenter
//
//  Created by Ravil Khusainov on 10.02.2016.
//  Copyright © 2016 Moqod. All rights reserved.
//

import UIKit
import Griddle

class CollectionViewController: UIViewController {

    @IBOutlet var collectionView: UICollectionView!
	
	var presenter: DraggableCollectionPresenter<ArraySource<String>>!
	lazy var dataSource: ArraySource<String> = ["First", "Second", "Third"]
	
	var collectionLayout: DraggableCollectionViewFlowLayout? {
		let layout = collectionView.collectionViewLayout as? DraggableCollectionViewFlowLayout
		return layout
	}
	
	var newDragGestureForCell: UILongPressGestureRecognizer {
		let longPressGestureRecogniser = UILongPressGestureRecognizer(target: self.collectionLayout, action: #selector(DraggableCollectionViewFlowLayout.handleGesture(_:)))
		longPressGestureRecogniser.delegate = self.collectionLayout
		longPressGestureRecogniser.minimumPressDuration = 0.2
		
		return longPressGestureRecogniser
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpView()
		
		let map = DefaultMap()
		map.registrationItems = [ RegistrationItem(viewType: .nib(UINib(nibName: "MocCollectionCell", bundle: nil)), id: "Cell") ]
		map.viewInfoGeneration = { _,_ in ViewInfo(identifier:"Cell", viewClass: MocCollectionCell.self) }
		
		presenter = DraggableCollectionPresenter(collectionView, source: dataSource, map: map)
		presenter.delegate.didUpdateCell = { [unowned self] cell, _, _ in
			if let cell = cell as? MocCollectionCell {
				cell.longPressGesture = self.newDragGestureForCell
			}
		}
		presenter.delegate.didSelectCell = { [unowned self] _, _, path in
			self.removeItem(at: path.index)
		}
    }
    
    func setUpView() {
        collectionLayout?.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
        collectionLayout?.minimumInteritemSpacing = 10.0
        collectionLayout?.minimumLineSpacing = 10.0
        collectionLayout?.itemSize = CGSize(width: 140, height: 140)
        collectionLayout?.scrollDirection = UICollectionViewScrollDirection.vertical
        collectionLayout?.animating = true
    }

	func removeItem(at index: Int) {
		let alert = UIAlertController(title: "Delete?", message: nil, preferredStyle: UIAlertControllerStyle.alert)
		alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.destructive, handler: { _ in
			self.dataSource.perform(actions: [.delete(index: index)])
		}))
		alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler:nil))
		present(alert, animated: true, completion: nil)
	}
	
    @IBAction func addAction(_ sender: AnyObject) {
        let alert = UIAlertController(title: "Insert After:", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        for (index, item) in dataSource.items.enumerated() {
            alert.addAction(UIAlertAction(title: item, style: UIAlertActionStyle.default, handler: { (action) in
                self.insertToIndex(index+1)
            }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
	
    func insertToIndex(_ index: Int) {
        let alert = UIAlertController(title: "Enter text:", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        alert.addTextField { (textfield) in
            
        }
        alert.addAction(UIAlertAction(title: "Add", style: UIAlertActionStyle.default, handler: { (action) in
            guard let text = alert.textFields?.first?.text else {return}
			self.dataSource.perform(actions: [.insert(index: index, model: text)])
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
