//
//  FetchedResultsSource.swift
//  CollectionPresenter
//
//  Created by Alex on 21/02/16.
//  Copyright © 2016 Moqod. All rights reserved.
//

import Foundation
import CoreData

final public class FetchedResultsSource<Model: NSFetchRequestResult>: DataSource {
	public var delegate: DataSourceDelegate {
		get { return controllerDelegate.delegate }
		set { controllerDelegate.delegate = newValue }
	}
	
	public func sections() -> [DictionarySection<String, Model>] {
		var sections: [DictionarySection<String, Model>] = []
		for section in controller.sections ?? [] {
			let header = section.name
			let objects = section.objects as? [Model] ?? []
			let sec = DictionarySection<String, Model>(header: header, items: objects)
			sections.append(sec)
		}
		return sections
	}
	
	public var sectionsCount: Int {
		return controller.sections?.count ?? 0
	}
	
    let controller: NSFetchedResultsController<Model>
	
	private let controllerDelegate = FetchedResultsSourceControllerDelegate()
	
    init(_ fetchedController: NSFetchedResultsController<Model>) {
        controller = fetchedController
        
        controller.delegate = controllerDelegate
    }
	
    deinit {
        controller.delegate = nil
    }
	
    func fetch() {
        _ = try? controller.performFetch()
        delegate.didRefreshAll()
    }
	
	public func itemsCount(for section: Int) -> Int {
		return controller.sections?[section].objects?.count ?? 0
	}
	
	public func item(at section: Int, index: Int) -> Model? {
		return controller.object(at: Foundation.IndexPath(row: index, section: section))
	}
	
	public func header(at section: Int) -> String? {
		guard let sections = controller.sections, section >= 0 && section < sections.count
			else { return nil }
		
		return sections[section].name
	}
	
	public func footer(at section: Int) -> Any? {
		return nil
	}
}

private class FetchedResultsSourceControllerDelegate: NSObject, NSFetchedResultsControllerDelegate {
	public var delegate = DataSourceDelegate()
	
	public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: Foundation.IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: Foundation.IndexPath?) {
		let update: DataSourceDelegate.UpdateInfo
		switch type {
		case .delete:
			update = .row(.delete(IndexPath(.table, indexPath!)))
			
		case .insert:
			update = .row(.insert(IndexPath(.table, newIndexPath!)))
			
		case .update:
			update = .row(.update(IndexPath(.table, indexPath!)))
			
		case .move:
			update = .row(.move(from: IndexPath(.table, indexPath!), to: IndexPath(.table, newIndexPath!)))
		}
		
		delegate.didUpdate(update)
	}
	
	public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
		let update: DataSourceDelegate.UpdateInfo
		switch type {
		case .delete:
			update = .section(.delete(sectionIndex))
			
		case .insert:
			update = .section(.insert(sectionIndex))
			
		case .update:
			update = .section(.update(sectionIndex))
			
		case .move:
			return
		}
		
		delegate.didUpdate(update)
	}
	
	public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		delegate.willBeginEditing()
	}
	public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		delegate.didEndEditing()
	}
}

// MARK: - Search
extension FetchedResultsSource {
    public func indexPath(for model: Any) -> IndexPath? {
        if let object = model as? String {
            if let index = controller.sections?.index(where: { $0.name == object }) {
				return .header(section: index)
            } else {
				return nil
			}
        }
		
		guard let object = model as? Model, let sections = controller.sections
			else { return nil }
		
        for (index, section) in sections.enumerated() {
			guard let objects = section.objects as? [Model]
				else { continue }
			
            for (row, item) in objects.enumerated() {
                if item.isEqual(object) {
					return .item(section: index, item: row)
                }
            }
        }
        return nil
    }
}
