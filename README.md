# Griddle

[![Join the chat at https://gitter.im/AlexIzh/Griddle](https://badges.gitter.im/AlexIzh/Griddle.svg)](https://gitter.im/AlexIzh/Griddle?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

Manager for simple work with UITableView, UICollectionView and any others collection structured views

## What is it?
It is layer for working with table view, collection view and any other views, which has collection structure.

## How it can help you?
1. You don't need implement delegate/dataSource of tableView/collectionView anymore. You just have one presenter, which do it instead of you.
2. You don't need care about data updating, you need just delete/add/move/replace/insert/etc elements in your data source class and view will get it automatically.
3. If you work with CoreData, you don't need care about updating data from NSFetchedResultsController anymore. Just use FetchedResultsSource and when data base will be changed, your UI will be changed at the same time.
4. Do you have universal application? iPad and iPhone versions has different views (collection view and table view, for example) but one package of data (For example, one screen on iphone has table view, but on ipad - collection)? All you need is to use different presenters and ONE data source. Don't need implement delegate and dataSource for different views with one data package anymore.
5. Do you have custom view with collection structure and you want to use this module? It is easy. Just implement your presenter which will work with your view.

## Installation
### CocoaPods
```
pod 'Griddle'
```
### Carthage
```
github "alexizh/Griddle"
```
## Examples
Current test project contains few simple examples:
1. Simple table view
2. Simple collection view
3. UITableView for iPhone, but UICollectionView for iPad
4. Custom view with collection structure
5. One UITableView, but few DataSource's

## Structure of module
This module contains 3 base objects:
1. Presenter - base class for working with UI. Only this object works with UI and implements delegate/data source of view if needed.
2. Data source - storage of models
3. Map - object returns information about views which should be used for model or index path

## Bit of code

```swift

  var presenter: TablePresenter<ArraySource<MenuCellModel>>!
  
  lazy var dataSource: ArraySource<MenuCellModel> = [
    MenuCellModel(title: "Table View", segueID: "Table"),
    MenuCellModel(title: "Collection View", segueID: "Collection"),
    MenuCellModel(title: "iPhone/iPad", segueID: "Universal"),
    MenuCellModel(title: "Custom View", segueID: "Custom"),
    MenuCellModel(title: "One table view, several data sources", segueID: "Segment")
  ]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    /* 
      It's just example of configuring map, you can create your own class/struct of map with conforming `Map` protocol. 
      In this case ArrayDataSource doesn't contain headers, so, it's just example how it could be.
    */
    let map = DefaultMap()
    map.registrationItems = [//it's used if views should be registered in container(tableView, collectionView, etc), you should not use it if views are registered automatically (for example, if you create tableView in xib)
      RegistrationItem(viewType: .nib(UINib(nibName: "MocTableCell", bundle: nil)), id: "Cell"),
      RegistrationItem(viewType: .viewClass(TableHeader.self), id: "Header", itemType: .header)
    ]
    map.viewInfoGeneration = { _, indexPath in
      if case .header(_) = indexPath {
        return ViewInfo(identifier: "Header", viewClass: TableHeader.self)
      } else {
        return ViewInfo(identifier: "Cell", viewClass: MocTableCell.self)
      }
    }
    
    presenter = TablePresenter(tableView, source: dataSource, map: map)
    presenter.delegate.didSelectCell = { [unowned self] _, model, _ in
      self.performSegue(withIdentifier: model.segueID, sender: nil)
    }
  }
  ```

Or if you have screen with `UITableView` for iPhone and `UICollectionView` for iPad:
```swift
@IBOutlet var tableView: UITableView?
@IBOutlet var collectionView: UICollectionView?

var presenter: Presenter<YourDataSource>!
var yourDataSource = YourDataSource()

override func viewDidLoad() {
  super.viewDidLoad()
  if let tableView = tableView {
    let map = DefaultMap()
    map.viewInfoGeneration = { _, _ in ViewInfo(identifier: "Cell", viewClass: MocTableCell.self) }
    
    presenter = TablePresenter(tableView, source: yourSource, map: map)
  } else if let collectionView = collectionView {
    let map = DefaultMap()
    map.viewInfoGeneration = { _, _ in ViewInfo(identifier: "Cell", viewClass: MocCollectionCell.self) }
    
    presenter = CollectionPresenter(collectionView, source: yourSource, map: map)
  } else {
    fatalError("You forgot to setup tableView or collectionView")
  }
  
  presenter.delegate.didSelectCell = { [unowned self] cell, model, path in
    print("\(model) is selected at \(path)")
  }
}
```
