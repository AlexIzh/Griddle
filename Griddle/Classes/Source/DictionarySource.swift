//
//  DictionarySource.swift
//  CollectionPresenter
//
//  Created by Alex on 20/02/16.
//  Copyright © 2016 Moqod. All rights reserved.
//

import Foundation

public struct DictionarySection<Key: Hashable, Value>: DataSection {

   public var header: Key?
   public var footer: Any? { return nil }
   public var items: [Value] = []

   public init(header: Key, items: [Value] = []) {
      self.header = header
      self.items = items
   }
}

// It's just example class. It contains disordered sections list.
open class DictionarySource<Key: Hashable, SourceValue>: DataSource, ExpressibleByDictionaryLiteral {

   public var delegate = DataSourceDelegate()

   private var items: [DictionarySection<Key, SourceValue>] = []

   public var sectionsCount: Int { return items.count }

   public func sections() -> [DictionarySection<Key, SourceValue>] {
      return items
   }

   public func itemsCount(for section: Int) -> Int {
      return items[section].items.count
   }

   public func item(at section: Int, index: Int) -> SourceValue? {
      return items[section].items[index]
   }

   public func header(at section: Int) -> Key? {
      return items[section].header
   }

   public func footer(at section: Int) -> Any? {
      return nil
   }

   public required init(dictionaryLiteral elements: (Key, [SourceValue])...) {
      var dic: [Key: [SourceValue]] = [:]
      for (key, array) in elements {
         dic[key] = array
      }
      dictionary = dic
   }

   public var dictionary: [Key: [SourceValue]] {
      get {
         var dictionary: [Key: [SourceValue]] = [:]
         items.forEach { dictionary[$0.header!] = $0.items }
         return dictionary
      }
      set {
         var sections: [DictionarySection<Key, SourceValue>] = []
         for (key, value) in newValue {
            var section = DictionarySection<Key, SourceValue>(header: key, items: [])
            for obj in value {
               section.items.append(obj)
            }
            sections.append(section)
         }
         items = sections

         delegate.didRefreshAll()
      }
   }

   public subscript(key: Key) -> [SourceValue]? {
      get {
         let section = items.index(where: { $0.header == key }).map { items[$0] }
         return section?.items
      }
      set(newValue) {
         dictionary[key] = newValue
      }
   }

   public func deleteItem(at section: Int, index: Int) {
      items[section].items.remove(at: index)
      delegate.didUpdate(.row(.delete(.item(section: section, item: index))))
   }
}
