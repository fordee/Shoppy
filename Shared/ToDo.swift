//
//  ToDo.swift
//  Shoppy
//
//  Created by John Forde on 17/1/18.
//  Copyright © 2018 4DWare. All rights reserved.
//

import Foundation

public struct ToDoItem: Codable {
	var category: String
	var description: String
	var done: String

	init(category: String, description: String, done: String) {
		self.category = category
		self.description = description
		self.done = done
	}
}

public struct ToDoList: Sequence, Codable {

	public func makeIterator() -> IndexingIterator<[ToDoList.Element]> {
		return list.makeIterator()
	}

	private var list: [ToDoItem] = []

	var allItems: [ToDoItem] {
		return list
	}

	var count: Int {
		return list.count
	}

	init(list: [ToDoItem]) {
		self.list = list
	}

	init() {
		let list: [ToDoItem] = []
		self.init(list: list)
	}

	mutating func addItem(_ item: ToDoItem) {
		list.append(item)
	}

	var itemCount: Int = 0

	public typealias Element = ToDoItem
	public typealias Iterator = IndexingIterator<[Element]>


	public mutating func next() -> Int? {
		if itemCount == 0 {
			return nil
		} else {
			defer { itemCount += 1 }
			return itemCount
		}
	}
}

