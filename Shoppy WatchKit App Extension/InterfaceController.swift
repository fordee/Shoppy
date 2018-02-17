//
//  InterfaceController.swift
//  Shoppy WatchKit App Extension
//
//  Created by John Forde on 7/1/18.
//  Copyright © 2018 4DWare. All rights reserved.
//

import WatchKit
import Foundation

class InterfaceController: WKInterfaceController {

	@IBOutlet var resultsGroup: WKInterfaceGroup!
	@IBOutlet var loadingGroup: WKInterfaceGroup!
	@IBOutlet var loadingGroupLabel: WKInterfaceLabel!
	@IBOutlet var table: WKInterfaceTable!

	@IBAction func clearMenuItem() {
		clearPurchasedItems()
	}

	@IBAction func addMenuItem() {
		addItem()
	}

	@IBAction func refreshMenuItem() {
		shoppingList.clearAll()
		refreshItemsFromApi()
	}

	// Manages the state of the interface
	enum InterfaceState: Int {
		case loading
		case results
		case nodata
	}

	// Configure the interface based on the state of the search process
	var interfaceStatus: InterfaceState = InterfaceState.loading {
		didSet {
			loadingGroup.setHidden(true)
			resultsGroup.setHidden(true)

			switch interfaceStatus {
			case .loading:
				loadingGroupLabel.setText("Loading data...")
				loadingGroup.setHidden(false)
				break
			case .results:
				resultsGroup.setHidden(false)
				break
			case .nodata:
				loadingGroupLabel.setText("No items found...")
				loadingGroup.setHidden(false)
				break
			}
		}
	}

	func clearPurchasedItems() {
		let rowsToRemove = NSMutableIndexSet()
		var indexes: [Int] = []

		for (index, item) in shoppingList.allShoppingItems.enumerated() {
			if item.bought {
				rowsToRemove.add(index)
				if let item = shoppingList.getItem(at: index)  {
					print("Removing \(item.itemName). ")
					indexes.append(index)
				}
			}
		}
		guard indexes.count > 0 else {return}

		shoppingList.removeItems(at: indexes)
		table.removeRows(at: rowsToRemove as IndexSet)
	}

	private let shoppyApi = ShoppyWebService()
	private var shoppingList = ShoppingList()
	private var frequentItemList = FrequentItemList()

	override func awake(withContext context: Any?) {
		super.awake(withContext: context)
		refreshFrequentItemsFromApi()
		refreshItemsFromApi()
		//refreshTable()
	}

	override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
		if let item = shoppingList.getItem(at: rowIndex) {
			item.toggleBought()
			if let row = table.rowController(at: rowIndex) as? ShoppyRowController {
				row.setStrikethough(item: item)
			}
		}
		refreshTable()
	}

	private func refreshItemsFromApi() {
		interfaceStatus = .loading
		shoppyApi.getAllShoppingListItems() { toDoList, error in
			guard let toDoList = toDoList else {return}
			if toDoList.count == 0 {
				self.interfaceStatus = .nodata
			} else {
				self.interfaceStatus = .results
				for toDoListItem in toDoList {
					if toDoListItem.category == "Shopping" {
						let shoppingListItem = ShoppingListItem(itemName: toDoListItem.description, bought: toDoListItem.done == "true" ? true : false)
						self.shoppingList.addItem(item: shoppingListItem)
					}
				}
				self.refreshTable()
			}
		}
	}

	private func refreshFrequentItemsFromApi() {
		shoppyApi.getAllFrequentItems() { commonItemList, error in
			guard let commonItemList = commonItemList else {return}
			guard commonItemList.count != 0 else {return}
			self.interfaceStatus = .results
			for commonItem in commonItemList {
				self.frequentItemList.addItem(item: commonItem)
			}
		}
	}


	private func refreshTable() {
		shoppingList.sortPurchasedToBottom()
		table.setNumberOfRows(shoppingList.count, withRowType: "ShoppyRowType")
		for (index, shoppingItem) in shoppingList.allShoppingItems.enumerated() {
			let controller = table.rowController(at: index) as! ShoppyRowController
			controller.itemLabel.setAttributedText(NSMutableAttributedString(string: shoppingItem.itemName))
			controller.rowGroup.setBackgroundColor(color(for: index))
			controller.setStrikethough(item: shoppingItem)
		}
	}

	func addItem() {
		presentTextInputController(withSuggestions: frequentItemList.mostFrequentItems, allowedInputMode: .plain) {answers in
			if let answers = answers, let answer = answers.first as? String {
				print("\(answer)")
				let item = ShoppingListItem(itemName: answer, bought: false)
				self.shoppingList.addItem(item: item)
				self.shoppyApi.add(shoppingListItem: item) {_, error in
					if let error = error {
						print("API Error (Add): \(error)")
					}
				}
				self.refreshTable()
			}
		}
	}

	func color(for index: Int) -> UIColor {
		let itemCount = shoppingList.count - 1
		let val = (CGFloat(index) / CGFloat(itemCount)) * 0.5
		return UIColor(red: 1.0, green: val, blue: 65.0/255.0, alpha: 1.0)
	}

}
