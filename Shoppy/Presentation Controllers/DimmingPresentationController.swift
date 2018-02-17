//
//  DimmingPresentationController.swift
//  Shoppy
//
//  Created by John Forde on 29/1/18.
//  Copyright © 2018 4DWare. All rights reserved.
//

import UIKit

class DimmingPresentationController: UIPresentationController {

	lazy var dimmingView = GradientView(frame: CGRect.zero)

	override func presentationTransitionWillBegin() {
		dimmingView.frame = containerView!.bounds
		containerView!.insertSubview(dimmingView, at: 0)
		dimmingView.alpha = 0
		if let coordinator = presentedViewController.transitionCoordinator {
			coordinator.animate(alongsideTransition: { _ in
				self.dimmingView.alpha = 0.7
			}, completion: nil)
		}
	}

	override func dismissalTransitionWillBegin() {
		if let coordinator = presentedViewController.transitionCoordinator {
			coordinator.animate(alongsideTransition: { _ in
				self.dimmingView.alpha = 0
			}, completion: nil)
		}
	}

	override var shouldRemovePresentersView: Bool {
		return false
	}
}
