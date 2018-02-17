//
//  ShoppingList.swift
//  Shoppy
//
//  Created by John Forde on 7/1/18.
//  Copyright © 2018 4DWare. All rights reserved.
//

import Foundation

public class ShoppingListItem: Equatable {
	public static func ==(lhs: ShoppingListItem, rhs: ShoppingListItem) -> Bool {
		return lhs.itemName == rhs.itemName
	}

	var itemName = ""
	var bought = false
	//private let shoppyApi: ShoppyApi
	private let newShoppyApi = ShoppyWebService()


	public init(itemName: String, bought: Bool) {
		self.itemName = itemName
		self.bought = bought
		//shoppyApi = ShoppyApi()
	}

	convenience init(itemName: String) {
		self.init(itemName: itemName, bought: false)
	}

	public func toggleBought() {
		bought = !bought
		newShoppyApi.update(shoppingListItem: self) {_, error in
			if let error = error {
				print("API Error: \(error)")
			}
			return
		}
	}

}

public class ShoppingList {
	private var list: [ShoppingListItem] = []
	private let newShoppyApi: ShoppyWebService

	public var count: Int {
		get {
			return list.count
		}
	}
	public var allShoppingItems: [ShoppingListItem] {
		get {
			return list
		}
	}

	public init() {
		newShoppyApi = ShoppyWebService()
	}

	public func addItem(item: ShoppingListItem) {
		guard findIndex(for: item) == nil else {return}
		list.append(item)
	}

	public func sortPurchasedToBottom() {
		list.sort( by: {a, b in
			return (a.bought != b.bought) && a.bought == false
		})
	}

	public func toggleShoppingListItem(at index: Int) {
		if index > list.count - 1 {
			print("Error: index (\(index)) out of range in toggleShoppingListItemAtIndex (only \(list.count) items)")
			return
		}
		list[index].toggleBought()
	}

	public func getItem(at index: Int) -> ShoppingListItem? {
		if index > list.count - 1 {
			print("Error: index (\(index)) out of range in getItemAtIndex (only \(list.count) items)")
			return nil
		}
		return list[index]
	}

	public func removeItem(at index: Int) -> ShoppingListItem? {
		if index > list.count - 1 {
			print("Error: index (\(index)) out of range in removeItemAtIndex (only \(list.count) items)")
			return nil
		}
		newShoppyApi.delete(shoppingListItem: list[index]) {_, error in
			// TODO Process Errors
			if let error = error {
				print("API Error: \(error)")
			}
		}
		return list.remove(at: index)
	}

	public func removeItems(at indexes: [Int]) {
		for i in (0..<(indexes.count)).reversed() {
			_ = removeItem(at: indexes[i])
		}
	}

	public func clearAll() {
		list = []
	}

	public func findIndex(for item: ShoppingListItem) -> Int? {
		if let index = list.index(of: item) {
			return index
		} else {
			return nil
		}
	}


}
