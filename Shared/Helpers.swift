//
//  Helpers.swift
//  Shoppy
//
//  Created by John Forde on 20/1/18.
//  Copyright © 2018 4DWare. All rights reserved.
//

import UIKit

func uicolorFrom(hex rgbValue:UInt32)->UIColor{
	let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
	let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
	let blue = CGFloat(rgbValue & 0xFF)/256.0

	return UIColor(red:red, green:green, blue:blue, alpha:1.0)
}
