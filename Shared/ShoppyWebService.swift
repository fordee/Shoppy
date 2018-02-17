//
//  NewShoppyApi.swift
//  Shoppy
//
//  Created by John Forde on 17/2/18.
//  Copyright © 2018 4DWare. All rights reserved.
//
import Foundation

class ShoppyWebService: WebService {
	private var baseURL: URL? = URL(string: "api.example.com")
	init() {
		super.init(rootURL: baseURL!)
		let apiEndpoint = plistValues(bundle: Bundle.main) ?? ""
		baseURL = URL(string: apiEndpoint)!
		super.setRootURL(rootURL: baseURL!)
	}

	public func getAllShoppingListItems(completion: @escaping (_ toDoList: [ToDoItem]?, _ error: Error?)->()) {
		let path = "/items"
		let method: HttpMethod<ToDoItem> = .get
		let encodedPath = path.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed)!
		executeRequest(encodedPath, method: method) {(response: [ToDoItem]?, error: Error?) in
			DispatchQueue.main.async {
				guard let response = response else {
					completion(nil, error)
					return
				}
				completion(response, error)
			}
		}
	}

	public func getAllFrequentItems(completion: @escaping (_ toDoList: [FrequentItem]?, _ error: Error?)->()) {
		let path = "/common-items"
		let method: HttpMethod<FrequentItem> = .get
		let encodedPath = path.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed)!
		executeRequest(encodedPath, method: method) {(response: [FrequentItem]?, error: Error?) in
			DispatchQueue.main.async {
				guard let response = response else {
					completion(nil, error)
					return
				}
				completion(response, error)
			}
		}
	}

	public func add(shoppingListItem item: ShoppingListItem, completion: @escaping (_ toDoList: [ToDoItem]?, _ error: Error?)->()) {
		let path = "/items"
		let encodedPath = path.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed)!

		let toDoItem = convert(shoppingListItem: item)
		let method: HttpMethod = .post(data: toDoItem)
		executeRequest(encodedPath, method: method) {(response: [ToDoItem]?, error: Error?) in
			DispatchQueue.main.async {
				guard let response = response else {
					completion(nil, error)
					return
				}
				completion(response, error)
			}
		}
	}

	public func update(shoppingListItem item: ShoppingListItem, completion: @escaping (_ toDoList: [ToDoItem]?, _ error: Error?)->()) {
		let path = "/items"
		let encodedPath = path.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed)!

		let toDoItem = convert(shoppingListItem: item)
		let method: HttpMethod = .put(data: toDoItem)
		executeRequest(encodedPath, method: method) {(response: [ToDoItem]?, error: Error?) in
			DispatchQueue.main.async {
				guard let response = response else {
					completion(nil, error)
					return
				}
				completion(response, error)
			}
		}
	}

	public func delete(shoppingListItem item: ShoppingListItem, completion: @escaping (_ toDoList: [ToDoItem]?, _ error: Error?)->()) {
		let path = "/items"
		let encodedPath = path.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed)!

		let toDoItem = convert(shoppingListItem: item)
		let method: HttpMethod = .delete(data: "/\(toDoItem.description)/Shopping".addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed)!)
		executeRequest(encodedPath, method: method) {(response: [ToDoItem]?, error: Error?) in
			DispatchQueue.main.async {
				guard let response = response else {
					completion(nil, error)
					return
				}
				completion(response, error)
			}
		}
	}

	// MARK: Private functions
	private func convert(shoppingListItem item: ShoppingListItem) -> ToDoItem {
		return ToDoItem(category: "Shopping", description: item.itemName, done: item.bought ? "true" : "false")
	}

	private func plistValues(bundle: Bundle) -> String? {
		guard
			let path = bundle.path(forResource: "Auth0", ofType: "plist"),
			let values = NSDictionary(contentsOfFile: path) as? [String: Any]
			else {
				print("Missing Auth0.plist file with 'ClientId' and 'Domain' entries in main bundle!")
				return nil
		}

		guard
			let apiEndpoint = values["API Endpoint"] as? String
			else {
				print("Auth0.plist file at \(path) is missing 'API Endpoint' entry!")
				print("File currently has the following entries: \(values)")
				return nil
		}
		return apiEndpoint
	}
}
