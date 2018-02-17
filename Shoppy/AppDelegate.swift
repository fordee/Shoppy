//
//  AppDelegate.swift
//  Shoppy
//
//  Created by John Forde on 27/12/17.
//  Copyright © 2017 4DWare. All rights reserved.
//

import UIKit
import UserNotifications
import Auth0
import WatchConnectivity
//import AWSCore
//import AWSCognito

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
	var mainViewController: ShoppingListViewController?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		//let credentialProvider = AWSCognitoCredentialsProvider(regionType: .USEast1, identityPoolId: "4f23r7hfjpn68l1di1jecoce8h")
		//let configuration = AWSServiceConfiguration(region: .USEast1, credentialsProvider: credentialProvider)
		//AWSServiceManager.default().defaultServiceConfiguration = configuration
		mainViewController = (window?.rootViewController as? UINavigationController)?.topViewController as? ShoppingListViewController
		setupWatchConnectivity()
		registerForPushNotifications()
		return true
	}

	func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
		let tokenParts = deviceToken.map { data -> String in
			return String(format: "%02.2hhx", data)
		}

		let token = tokenParts.joined()
		print("Device Token: \(token)")
	}

	func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
		print("Failed to register: \(error)")
	}

	func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
		let aps = userInfo["aps"] as! [String: AnyObject]

		if aps["alert"] as? String == "New items have been added to your shopping list." {
			print("Refresh shopping list!")
			guard let vc = mainViewController else {return}
			vc.refreshItemsFromApi()
		}
	}

	func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
		return Auth0.resumeAuth(url, options: options)
	}

	func registerForPushNotifications() {
		UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
			granted, error in
			print("Permission granted: \(granted)")
			guard granted else { return }
			self.getNotificationSettings()
		}
	}

	func getNotificationSettings() {
		UNUserNotificationCenter.current().getNotificationSettings {
			settings in
			print("Notification settings: \(settings)")
			guard settings.authorizationStatus == .authorized else { return }
			DispatchQueue.main.async {
				UIApplication.shared.registerForRemoteNotifications()
			}
		}
	}

	func setupWatchConnectivity() {
		if WCSession.isSupported() {
			let session = WCSession.default
			session.delegate = self
			session.activate()
		}
	}
}

extension AppDelegate: WCSessionDelegate {
	func sessionDidBecomeInactive(_ session: WCSession) {
		print("WC Session did become inactive")
	}

	// 2
	func sessionDidDeactivate(_ session: WCSession) {
		print("WC Session did deactivate")
		WCSession.default.activate()
	}

	// 3
	func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
		if let error = error {
			print("WC Session activation failed with error: \(error.localizedDescription)")
			return
		}
		print("WC Session activated with state: \(activationState.rawValue)")
	}

}


