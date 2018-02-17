//
//  FrequentItem.swift
//  Shoppy
//
//  Created by John Forde on 1/2/18.
//  Copyright © 2018 4DWare. All rights reserved.
//

import Foundation

public struct FrequentItem: Codable {
	var ShoppingItem: String
	var Frequency: String

	var frequencyInt: Int? {
		return Int(Frequency)
	}

	init(description: String, frequency: String) {
		self.ShoppingItem = description
		self.Frequency = frequency
	}
}

public struct FrequentItemList: Sequence, Codable {
	public func makeIterator() -> IndexingIterator<[FrequentItem]> {
		return list.makeIterator()
	}

	public mutating func clearAll() {
		list = []
	}

	public mutating func addItem(item: FrequentItem) {
		list.append(item)
	}

	private var list: [FrequentItem] = []

	var allItems: [FrequentItem] {
		return list
	}

	var mostFrequentItems: [String] {
		let sortedFrequentItems = list.sorted { (a, b) -> Bool in
			a.frequencyInt! > b.frequencyInt!
		}
		return sortedFrequentItems.map { item in
			item.ShoppingItem
		}
	}

	var count: Int {
		return list.count
	}

	init(list: [FrequentItem]) {
		self.list = list
	}

	init() {
		let list: [FrequentItem] = []
		self.init(list: list)
	}

	mutating func addItem(_ item: FrequentItem) {
		list.append(item)
	}

	var itemCount: Int = 0

	public typealias Element = FrequentItem
	public typealias Iterator = IndexingIterator<[FrequentItem]>


	public mutating func next() -> Int? {
		if itemCount == 0 {
			return nil
		} else {
			defer { itemCount += 1 }
			return itemCount
		}
	}
}
