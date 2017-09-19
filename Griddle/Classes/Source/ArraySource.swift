//
//  ArraySource.swift
//  CollectionPresenter
//
//  Created by Alex on 20/02/16.
//  Copyright © 2016 Moqod. All rights reserved.
//

import Foundation

public enum ArrayAction<Model> {
   case insert(index: Int, model: Model)
   case delete(index: Int)
   case replace(index: Int, newModel: Model)
   case move(oldIndex: Int, newIndex: Int)
}

public struct ArraySection<Element>: DataSection {

   public var header: Any? { return nil }
   public var footer: Any? { return nil }
   public var items: [Element] = []

   public init(items: [Element] = []) {
      self.items = items
   }
}

open class ArraySource<Element>: DataSource, ExpressibleByArrayLiteral {

   public var delegate = DataSourceDelegate()

   private var section = ArraySection<Element>()

   public var sectionsCount: Int { return 1 }

   public var count: Int {
      return section.items.count
   }

   public var items: [Element] {
      get { return section.items }
      set {
         section.items = newValue
         delegate.didRefreshAll()
      }
   }

   public subscript(index: Int) -> Element {
      get { return section.items[index] }
      set {
         delegate.willBeginEditing()

         section.items[index] = newValue
         delegate.didUpdate(.row(.update(.item(section: 0, item: index))))

         delegate.didEndEditing()
      }
   }

   // MARK: - Life cycle
   public required convenience init(arrayLiteral elements: Element...) {
      self.init(array: elements)
   }

   public init(array: [Element]) {
      section.items = array
   }

   // MARK: - Public methods
   public func append(_ item: Element) {
      delegate.willBeginEditing()
      insert(item, at: items.count)
      delegate.didEndEditing()
   }

   public func sections() -> [ArraySection<Element>] {
      return [section]
   }

   public func itemsCount(for section: Int) -> Int {
      return self.section.items.count
   }

   public func item(at section: Int, index: Int) -> Element? {
      guard section == 0 && index >= 0 && index < self.section.items.count
      else { return nil }

      return self.section.items[index]
   }

   public func header(at section: Int) -> Any? {
      return nil
   }

   public func footer(at section: Int) -> Any? {
      return nil
   }

   public func perform(actions: [ArrayAction<Element>]) {
      delegate.willBeginEditing()

      for action in actions {
         switch action {
         case .insert(let index, let model): insert(model, at: index)
         case .delete(let index): deleteItem(at: index)
         case .move(let oldIndex, let newIndex): moveItem(from: oldIndex, to: newIndex)
         case .replace(let index, let newModel): replaceItem(at: index, with: newModel)
         }
      }

      delegate.didEndEditing()
   }

   // MARK: - Private methods
   func replaceItem(at index: Int, with model: Element) {
      section.items[index] = model
      delegate.didUpdate(.row(.update(.item(section: 0, item: index))))
   }

   func moveItem(from index: Int, to newIndex: Int) {
      let item = section.items[index]
      section.items.remove(at: index)
      section.items.insert(item, at: newIndex)
      delegate.didUpdate(.row(.move(from: .item(section: 0, item: index), to: .item(section: 0, item: newIndex))))
   }

   func deleteItem(at index: Int) {
      section.items.remove(at: index)
      delegate.didUpdate(.row(.delete(.item(section: 0, item: index))))
   }

   func insert(_ item: Element, at index: Int) {
      let insertIndex = index > section.items.count ? section.items.count : index
      section.items.insert(item, at: insertIndex)
      delegate.didUpdate(.row(.insert(.item(section: 0, item: index))))
   }
}
