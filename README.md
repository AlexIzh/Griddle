# Griddle
Manager for simple work with UITableView, UICollectionView and any others collection structured views

## What is it?
It is layer for working with table view, collection view and any other views, which has collection structure.

## How it can help you?
1. You don't need implement delegate/dataSource of tableView/collectionView anymore. You just have one presenter, which do it instead of you.
2. You don't need care about data updating, you need just delete/add/move/replace/insert/etc elements in your data source class and view will get it automatically.
3. If you work with CoreData, you don't need care about updating data from NSFetchedResultsController anymore. Just use FetchedResultsSource and when data base will be changed, your UI will be changed at the same time.
4. Do you have universal application? iPad and iPhone versions has different views (collection view and table view, for example) but one package of data (For example, one screen on iphone has table view, but on ipad - collection)? All you need is to use different presenters and ONE data source. Don't need implement delegate and dataSource for different views with one data package anymore.
5. Do you have custom view with collection structure and you want to use this module? It is easy. Just implement your presenter which will work with your view.

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
