//
//  AlertController+Loading.swift.swift
//  Shoppy
//
//  Created by John Forde on 6/2/18.
//  Copyright © 2018 4DWare. All rights reserved.
//

import UIKit

extension UIAlertController {

	static func loadingAlert() -> UIAlertController {
		return UIAlertController(title: "Loading", message: "Please, wait...", preferredStyle: .alert)
	}

	func presentInViewController(_ viewController: UIViewController) {
		viewController.present(self, animated: true, completion: nil)
	}
}
