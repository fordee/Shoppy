//
//  ViewController.swift
//  Shoppy
//
//  Created by John Forde on 27/12/17.
//  Copyright © 2017 4DWare. All rights reserved.
//

import UIKit
import Auth0

class ShoppingListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var loginButton: UIBarButtonItem!

	private let tintColor = UIColor(red:0.25, green:0.72, blue:0.85, alpha:1.0)

	//private let shoppyApi = ShoppyApi()

	private let newShoppyApi = ShoppyWebService()

	private var shoppingList = ShoppingList()
	private var frequentItemList = FrequentItemList()

	private let refreshControl = UIRefreshControl()
	private var floatingAddButton: FloatingAddButton?

	@IBAction func onLoginButton(_ sender: Any) {
		if loginButton.title == "Login" {
			checkToken()
		} else {
			if SessionManager.shared.logout() {
				loginButton.title = "Login"
			}
		}
	}

	@IBAction func onDeleteButton(_ sender: Any) {
		clearPurchasedItems()
	}



	override func viewDidLoad() {
		super.viewDidLoad()
		setupTableView()
		floatingAddButton = FloatingAddButton(parentView: view, color: tintColor) {
			self.viewTapped()
		}
		floatingAddButton?.show()

		if SessionManager.shared.credentialsManager.hasValid() {
			loginButton.title = "Logout"
		} else {
			loginButton.title = "Login"
		}
		checkToken()
		print("Token: \(String(describing: SessionManager.shared.credentials?.idToken!))")


	}

	// MARK: - Private

	private func refreshAll() {
		refreshItemsFromApi()
		refreshFrequentItemsFromApi()
	}

	private func setupTableView() {
		tableView.backgroundColor = uicolorFrom(hex: 0xFBFACE)
		tableView.delegate = self
		tableView.dataSource = self
		tableView.refreshControl = refreshControl
		refreshControl.addTarget(self, action: #selector(refreshShoppingList(_:)), for: .valueChanged)
		refreshControl.tintColor = tintColor
		refreshControl.attributedTitle = NSAttributedString(string: "Fetching Shopping List ...", attributes: nil)
	}

	@objc private func refreshShoppingList(_ sender: Any) {
		refreshItemsFromApi()
	}

	private func viewTapped() {
		print("Tapped!")
		floatingAddButton?.hide()
		addItem()
	}

	private func showLogin() {
		guard let clientInfo = plistValues(bundle: Bundle.main) else { return }
		Auth0
			.webAuth()
			.scope("openid profile offline_access")
			.audience("https://" + clientInfo.domain + "/userinfo")
			.start { result in
				switch result {
				case .failure(let error):
					print("Error: \(error)")
				case .success(let credentials):
					if(!SessionManager.shared.store(credentials: credentials)) {
						print("Failed to store credentials")
					} else {
						SessionManager.shared.retrieveProfile { error in
							DispatchQueue.main.async {
								guard error == nil else {
									print("Failed to retrieve profile: \(String(describing: error))")
									return self.showLogin()
								}
								//self.performSegue(withIdentifier: "ShowProfileAnimated", sender: nil)
								print("showLogin Token: \(String(describing: SessionManager.shared.credentials?.idToken))")
								self.loginButton.title = "Logout"
								self.refreshAll()
							}
						}
					}
				}
		}
	}

	private func checkToken() {
		let loadingAlert = UIAlertController.loadingAlert()
		loadingAlert.presentInViewController(self)
		SessionManager.shared.renewAuth { error in
			DispatchQueue.main.async {
				loadingAlert.dismiss(animated: true) {
					guard error == nil else {
						print("Failed to retrieve credentials: \(String(describing: error))")
						return self.showLogin()
					}
					SessionManager.shared.retrieveProfile { error in
						DispatchQueue.main.async {
							guard error == nil else {
								print("Failed to retrieve profile: \(String(describing: error))")
								return self.showLogin()
							}
							print("checkToken Token: \(String(describing: SessionManager.shared.credentials?.idToken!))")
							self.loginButton.title = "Logout"
							self.refreshAll()
							//self.performSegue(withIdentifier: "ShowProfileAnimated", sender: nil)
						}
					}
				}
			}
		}
	}


	func refreshItemsFromApi() {
		//interfaceStatus = .loading
		shoppingList.clearAll()
//		shoppyApi.getAllShoppingListItems() {
//			toDoList in
//			if toDoList.count == 0 {
//				//self.interfaceStatus = .nodata
//			} else {
//				//self.interfaceStatus = .results
//				for toDoListItem in toDoList {
//					if toDoListItem.category == "Shopping" {
//						let shoppingListItem = ShoppingListItem(itemName: toDoListItem.description, bought: toDoListItem.done == "true" ? true : false)
//						self.shoppingList.addItem(item: shoppingListItem)
//					}
//				}
//				self.shoppingList.sortPurchasedToBottom()
//				self.tableView.reloadData()
//				self.refreshControl.endRefreshing()
//			}
//		}

		newShoppyApi.getAllShoppingListItems() { toDoList, error in
			//self.interfaceStatus = .loading
			if (error != nil) {
				print("Error in API")
				self.refreshControl.endRefreshing()
				return
			}
			guard let toDoList = toDoList else {return}
			if toDoList.count == 0 {
				//self.interfaceStatus = .nodata
			} else {
				//self.interfaceStatus = .results
				for toDoListItem in toDoList {
					if toDoListItem.category == "Shopping" {
						let shoppingListItem = ShoppingListItem(itemName: toDoListItem.description, bought: toDoListItem.done == "true" ? true : false)
						self.shoppingList.addItem(item: shoppingListItem)
						print("Item: \(shoppingListItem.itemName)")
					}
				}
				self.shoppingList.sortPurchasedToBottom()
				self.tableView.reloadData()
			}
			self.refreshControl.endRefreshing()
		}
	}

	func refreshFrequentItemsFromApi() {
		//interfaceStatus = .loading
		frequentItemList.clearAll()
		newShoppyApi.getAllFrequentItems { commonItemList, error in
			if commonItemList?.count == 0 {
				//self.interfaceStatus = .nodata
			} else {
				//self.interfaceStatus = .results
				guard let commonItemList = commonItemList else {return}
				for commonItem in commonItemList {
					self.frequentItemList.addItem(item: commonItem)
				}
				print("Most frequent items: \(self.frequentItemList.mostFrequentItems)")
			}
		}
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if let cell = tableView.cellForRow(at: indexPath) {
			if let item =  shoppingList.getItem(at: indexPath.row) {
				item.toggleBought()
				let label = cell.viewWithTag(1000) as! UILabel
				setStrikethough(item: item, label: label)
			}
		}
		tableView.deselectRow(at: indexPath, animated: true)
		self.shoppingList.sortPurchasedToBottom()
		self.tableView.reloadData()
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "ShoppingListItem", for: indexPath)
		if let item = shoppingList.getItem(at: indexPath.row) {
			let label = cell.viewWithTag(1000) as! UILabel
			setStrikethough(item: item, label: label)
			return cell
		}
		return UITableViewCell()
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return shoppingList.count
	}

	func setStrikethough(item: ShoppingListItem, label: UILabel) {
		let attributedText = NSMutableAttributedString(string: item.itemName)
		if item.bought {
			attributedText.addAttribute(NSAttributedStringKey.strikethroughStyle, value: 1, range: NSMakeRange(0, attributedText.length))
			// Dim the interface
			label.alpha = 0.5
		} else {
			attributedText.addAttribute(NSAttributedStringKey.strikethroughStyle, value: 0, range: NSMakeRange(0, attributedText.length))
			label.alpha = 1.0
		}
		label.attributedText = attributedText
	}

	func clearPurchasedItems() {
		var rowsToRemove: [IndexPath] = []//NSMutableIndexSet()
		var indexes: [Int] = []

		for (index, item) in shoppingList.allShoppingItems.enumerated() {
			if item.bought {
				rowsToRemove.append(IndexPath(row: index, section: 0))
				if let item = shoppingList.getItem(at: index)  {
					print("Removing \(item.itemName). ")
					indexes.append(index)
				}
			}
		}
		guard indexes.count > 0 else {return}

		shoppingList.removeItems(at: indexes)
		tableView.deleteRows(at: rowsToRemove, with: .automatic) //(at: rowsToRemove as IndexSet)
	}

	func addItem() {
		if let controller = storyboard!.instantiateViewController(withIdentifier: "AddViewController") as? AddViewController {
			controller.delegate = self
			controller.commonList = frequentItemList.mostFrequentItems
			present(controller, animated: true, completion: nil)
		}
	}

	deinit {
		floatingAddButton?.removeControl()
	}

}

extension ShoppingListViewController: AddDelegate {
	func addShoppingItem(addViewController: AddViewController) {
		if let item = addViewController.shoppingListItem {
			newShoppyApi.add(shoppingListItem: item) {toDoList, error in
				if (error != nil) {
					print("Error in API (Add)")
				}
				self.shoppingList.addItem(item: item)
				// Check for error
				self.tableView.reloadData()
			}
		}
	}

	func close(addViewController: AddViewController) {
		floatingAddButton?.show()
	}

}

