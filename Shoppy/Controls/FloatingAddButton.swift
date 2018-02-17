//
//  FloatingAddButton.swift
//  Shoppy
//
//  Created by John Forde on 23/1/18.
//  Copyright © 2018 4DWare. All rights reserved.
//

import UIKit

@IBDesignable
class FloatingAddButton {

	// MARK: Public variables
	@IBInspectable
	let controlWidth  : CGFloat = 54

	@IBInspectable
	let controlHeight : CGFloat = 54

	let plusWidth: CGFloat = 4
	let plusInset: CGFloat = 10

	let padding: CGFloat = 20
	let statusAndNavBarHeight: CGFloat = 64

	// MARK: Private variables

	private var parentView: UIView!
	private var controlView: UIControl!
	private var controlColor: UIColor = UIColor.red
	private var completion: (()->())?

	private lazy var controlBackgroundLayer : CAShapeLayer = {
		let layer = CAShapeLayer()
		layer.contentsScale = UIScreen.main.scale
		layer.backgroundColor = controlColor.cgColor
		layer.shadowColor = UIColor.black.cgColor
		layer.shadowOffset = CGSize(width: 3.0, height: 3.0)
		layer.shadowOpacity = 0.3
		layer.masksToBounds = false
		layer.anchorPoint = CGPoint(x: 0, y: 0)

		return layer
	}()

	private lazy var controlForeground1Layer : CAShapeLayer = {
		let layer = CAShapeLayer()
		layer.contentsScale = UIScreen.main.scale
		layer.backgroundColor = UIColor.clear.cgColor
		layer.fillColor = UIColor.white.cgColor
		layer.path = CGPath(roundedRect: CGRect(x: (controlWidth / 2) - (plusWidth / 2), y: plusInset, width: plusWidth, height: controlHeight - (plusInset * 2)), cornerWidth: (plusWidth / 2), cornerHeight: (plusWidth / 2), transform: nil)
		layer.anchorPoint = CGPoint(x: 0, y: 0)
		return layer
	}()

	private lazy var controlForeground2Layer : CAShapeLayer = {
		let layer = CAShapeLayer()
		layer.contentsScale = UIScreen.main.scale
		layer.backgroundColor = UIColor.clear.cgColor
		layer.fillColor = UIColor.white.cgColor
		layer.path = CGPath(roundedRect: CGRect(x: plusInset, y: (controlHeight / 2) - (plusWidth / 2), width: controlWidth - (plusInset * 2), height: plusWidth), cornerWidth: (plusWidth / 2), cornerHeight: (plusWidth / 2), transform: nil)
		layer.anchorPoint = CGPoint(x: 0, y: 0)
		return layer
	}()

	private var layerCenter : CGPoint!
	private var position   	: CGPoint = CGPoint.zero
	private let screenSizeX = UIApplication.shared.keyWindow!.bounds.width
	private let screenSizeY = UIApplication.shared.keyWindow!.bounds.height


	// MARK: init()
	init(parentView: UIView,
			 color: UIColor = UIColor.red,
			 position: CGPoint = CGPoint.zero,
			 completion: (()->())?) {

		self.parentView		= parentView
		self.position			= position
		self.controlColor = color
		self.completion = completion

		let screenSize = UIScreen.main.bounds.size
		if self.position == CGPoint.zero {
			self.position.x = screenSize.width - controlWidth - padding
			self.position.y = screenSize.height - controlHeight - padding - statusAndNavBarHeight
		}

		let frame = CGRect(x: self.position.x, y: self.position.y, width: controlWidth, height: controlHeight)

		// Animate to make to look like it is opening

		controlView = UIControl(frame: frame)
		controlView.addTarget(self, action: #selector(onTouch), for: .touchUpInside)
		controlView.isUserInteractionEnabled = true
		//layerCenter = CGPoint(x: controlView.bounds.width / 2, y: controlView.bounds.height / 2)
		controlBackgroundLayer.cornerRadius = controlView.bounds.width / 2
		controlBackgroundLayer.fillColor = controlColor.cgColor

		layoutLayers()
		parentView.addSubview(controlView)
	}

	@objc func onTouch(sender: UIButton) {
		print("You tapped button")
		completion?()
	}

	func show() {
		controlView.alpha = 0
		controlView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)

		UIView.animate(withDuration: 0.3, delay: 0.5, usingSpringWithDamping: 0.7,
									 initialSpringVelocity: 0.5, options: [], animations: {
										self.controlView.alpha = 1
										self.controlView.transform = CGAffineTransform.identity
		},
									 completion: nil)
	}

	func hide() {
		UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7,
									 initialSpringVelocity: 0.5, options: [], animations: {
										self.controlView.alpha = 0
										self.controlView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
		},
									 completion: nil)
	}

	// MARK: Public functions
	func removeControl() {
		controlView.removeFromSuperview()
	}

	// MARK: Private functions
	private func layoutLayers() {
		for layer in [controlBackgroundLayer, controlForeground1Layer, controlForeground2Layer] as [Any] {
			(layer as! CALayer).bounds = controlView.bounds
			controlView.layer.addSublayer(layer as! CALayer)
		}
	}

}

