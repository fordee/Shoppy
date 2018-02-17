//
//  AddViewController.swift
//  Shoppy
//
//  Created by John Forde on 28/1/18.
//  Copyright © 2018 4DWare. All rights reserved.
//

import UIKit

protocol AddDelegate {
	func addShoppingItem(addViewController: AddViewController)
	func close(addViewController: AddViewController)
}

class AddViewController: UIViewController {

	@IBOutlet weak var popupView: UIView!
	@IBOutlet weak var itemTextField: UITextField!
	@IBOutlet weak var tableView: UITableView!
	
	@IBAction func onAddButton(_ sender: Any) {
		if let text = itemTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), text.count > 0 {
			shoppingListItem = ShoppingListItem(itemName: text)
		}
		delegate?.addShoppingItem(addViewController: self)
		itemTextField.text = ""
	}

	@IBAction func onCloseButton(_ sender: Any) {
		delegate?.close(addViewController: self)
		dismiss(animated: true, completion: nil)
	}

	var commonList: [String] = []//["beer", "milk", "sugar", "coffee", "dog food", "toilet paper", "washing powder", "toothpaste", "bananas", "dishwasher powder"]

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		modalPresentationStyle = .custom
		transitioningDelegate = self
	}

	var shoppingListItem: ShoppingListItem? = nil

	var delegate: AddDelegate?

	override func viewDidLoad() {
		super.viewDidLoad()
		popupView.layer.cornerRadius = 10
		view.backgroundColor = UIColor.clear
		itemTextField.becomeFirstResponder()

		//tableView.backgroundColor = uicolorFrom(hex: 0xFBFACE)
		tableView.delegate = self
		tableView.dataSource = self
		tableView.estimatedRowHeight = 34

	}
}

extension AddViewController: UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "CommonItem", for: indexPath)
		let label = cell.viewWithTag(1000) as! UILabel
		let attributedText = NSMutableAttributedString(string: commonList[indexPath.row])
		attributedText.addAttribute(NSAttributedStringKey.strikethroughStyle, value: 0, range: NSMakeRange(0, attributedText.length))
		label.attributedText = attributedText
		return cell
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return commonList.count
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		itemTextField.text = commonList[indexPath.row]
		tableView.deselectRow(at: indexPath, animated: true)
	}

}

extension AddViewController: UIViewControllerTransitioningDelegate {
	func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
		return DimmingPresentationController(presentedViewController: presented, presenting: presenting)
	}

	func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
			return SlideInAnimationController()//BounceAnimationController()
	}

	func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return SlideOutAnimationController()
	}
}

