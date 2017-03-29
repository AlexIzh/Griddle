//
//  ItemsView.swift
//  CollectionPresenter
//
//  Created by Alex on 22/03/16.
//  Copyright © 2016 Moqod. All rights reserved.
//

import Foundation
import UIKit

protocol ItemsViewDataSource: class {
    func numberOfItems(in view: ItemsView) -> Int
    func viewForItem(at index: Int) -> ItemView
    func coordinatesForItem(at index: Int) -> CGPoint //x and y should be 0..<1
    func sizeForItem(at index: Int) -> CGSize
}

protocol ItemsViewDelegate: class {
    func view(_ view: ItemsView, didSelectItemAt index: Int)
}

class ItemsView: UIView {
    weak var dataSource: ItemsViewDataSource?
    weak var delegate: ItemsViewDelegate?
	
	fileprivate var views: [ItemView] = []
	
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func removeAllItemViews() {
        views.forEach { $0.removeFromSuperview() }
        views.removeAll()
    }
	
	func reloadData() {
        defer {
            self.setNeedsLayout()
        }
        removeAllItemViews()
		
        guard let source = dataSource else { return }
        
		let count = source.numberOfItems(in: self)
        for i in 0..<count {
            let view: ItemView = generateViewForIndex(i)!
            addSubview(view)
            views.append(view)
        }
		
        setNeedsLayout()
    }
	
    fileprivate func generateViewForIndex(_ i:Int) -> ItemView? {
        guard let source = dataSource else { return nil }
		let view: ItemView = source.viewForItem(at: i)
        view.addTarget(self, action: #selector(selectItemView(_:)), for: .touchUpInside)
        return view
    }
	
    override func layoutSubviews() {
        super.layoutSubviews()
        self.updateViewsPosition()
    }
	
    fileprivate func updateViewsPosition() {
        for (index, view) in views.enumerated() {
			let centerPercents = dataSource?.coordinatesForItem(at: index) ?? .zero
            let center = centerPercents.absolutePoint(self.bounds.size)
			let size = dataSource?.sizeForItem(at: index) ?? .zero
            view.frame = CGRect(x: center.x - size.width/2.0, y: center.y - size.height/2.0, width: size.width, height: size.height)
        }
    }
	
    func view(for index: Int) -> ItemView {
        return views[index]
    }
	
    func moveItem(from: Int, to: Int) {
        let view = views[from]
        view.removeFromSuperview()
        views.remove(at: from)
        views.insert(view, at: to)
        insertSubview(view, at: to)
        setNeedsLayout()
    }
    func reloadItem(at index:Int) {
		deleteItem(at: index)
		insertItem(at: index)
    }
    func insertItem(at index:Int) {
        if let view = generateViewForIndex(index) {
            insertSubview(view, at: index)
            views.insert(view, at: index)
            setNeedsLayout()
        }
    }
    func deleteItem(at index:Int) {
        let view = views[index]
        view.removeFromSuperview()
        views.remove(at: index)
        setNeedsLayout()
    }
    
    func selectItemView(_ sender: ItemView) {
        let index = views.index(of: sender)
        delegate?.view(self, didSelectItemAt: index ?? 0)
    }
}

private extension CGPoint {
    func absolutePoint(_ size: CGSize) -> CGPoint {
        var absolute = self
        absolute.y = 1.0 - absolute.y
        absolute.y *= size.height
        absolute.x *= size.width
        return absolute
    }
    func relativePoint(_ size: CGSize) -> CGPoint {
        var relative = self
        relative.x /= size.width
        relative.y /= size.height
        relative.y = 1.0 - relative.y
        return relative
    }
}
