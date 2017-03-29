//
//  UniversalController.swift
//  CollectionPresenter
//
//  Created by Alex on 31/03/16.
//  Copyright © 2016 Moqod. All rights reserved.
//

import Foundation
import UIKit
import CollectionPresenterFramework

class UniversalController: UIViewController {
    var contentView: UIView!
    var presenter: Presenter<ArraySource<String>>?
    lazy var dataSource: ArraySource<String> = {
        return ["First", "Second", "Third"]
    }()
	
    override func viewDidLoad() {
        super.viewDidLoad()
        createPresenter()
		
        view.addSubview(contentView)
    }
	
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        contentView.frame = view.bounds
    }
	
    //MARK: - Create presenter
    func createPresenter() {
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            return createTablePresenter()
        }
        return createCollectionPresenter()
    }
	
    func createTablePresenter() {
        let tableView = generateTableView()
        contentView = tableView
		
		presenter = TablePresenter(tableView, source: dataSource, map: PhoneMap())
    }
	
    func createCollectionPresenter() {
        let collectionView = generateCollectionView()
        contentView = collectionView
		
		presenter = CollectionPresenter(collectionView, source: dataSource, map: PadMap())
    }
	
    //MARK: - Generation
    func generateTableView() -> UITableView {
        let tableView = UITableView()
        return tableView
    }
	
    func generateCollectionView() -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.minimumInteritemSpacing = 10.0
        layout.minimumLineSpacing = 10.0
        layout.itemSize = CGSize(width: 140, height: 140)
        layout.scrollDirection = .vertical
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }
}
