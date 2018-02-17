//
//  Shoppy Row Controller.swift
//  Shoppy
//
//  Created by John Forde on 7/1/18.
//  Copyright © 2018 4DWare. All rights reserved.
//

import WatchKit

class ShoppyRowController: NSObject {
	@IBOutlet var itemLabel: WKInterfaceLabel!
	@IBOutlet var rowGroup: WKInterfaceGroup!
	
	func setStrikethough(item: ShoppingListItem) {
		let attributedText = NSMutableAttributedString(string: item.itemName)
		if item.bought {
			attributedText.addAttribute(NSAttributedStringKey.strikethroughStyle, value: 1, range: NSMakeRange(0, attributedText.length))
			// Dim the interface
			itemLabel.setAlpha(0.5)
		} else {
			attributedText.addAttribute(NSAttributedStringKey.strikethroughStyle, value: 0, range: NSMakeRange(0, attributedText.length))
			itemLabel.setAlpha(1.0)
		}

		itemLabel.setAttributedText(attributedText)
	}

}
