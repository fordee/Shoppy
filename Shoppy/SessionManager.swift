//
//  SessionManager.swift
//  Shoppy
//
//  Created by John Forde on 6/2/18.
//  Copyright © 2018 4DWare. All rights reserved.
//

import Foundation
import Auth0
import WatchConnectivity


class SessionManager {
	static let shared = SessionManager()
	private let authentication = Auth0.authentication()
	let credentialsManager: CredentialsManager!
	var profile: UserInfo?
	var credentials: Credentials?

	private init () {
		self.credentialsManager = CredentialsManager(authentication: Auth0.authentication())
		//self.credentialsManager.enableBiometrics(withTitle: "Touch to Authenticate, or Cancel to login with your userid and password.")
		// _ = self.authentication.logging(enabled: true) // API Logging
	}

	func retrieveProfile(_ callback: @escaping (Error?) -> ()) {
		guard let accessToken = self.credentials?.accessToken
			else { return callback(CredentialsManagerError.noCredentials) }
		self.authentication
			.userInfo(withAccessToken: accessToken)
			.start { result in
				switch(result) {
				case .success(let profile):
					self.profile = profile
					callback(nil)
				case .failure(let error):
					callback(error)
				}
		}
	}

	func renewAuth(_ callback: @escaping (Error?) -> ()) {
		// Check it is possible to return credentials before asking for Touch
		guard self.credentialsManager.hasValid() else {
			return callback(CredentialsManagerError.noCredentials)
		}
		self.credentialsManager.credentials { error, credentials in
			guard error == nil, let credentials = credentials else {
				return callback(error)
			}
			self.credentials = credentials
			callback(nil)
		}
	}

	func logout() -> Bool {
		// Remove credentials from KeyChain
		self.credentials = nil
		return self.credentialsManager.clear()
	}

	func store(credentials: Credentials) -> Bool {
		self.credentials = credentials
		
		// Share token with AppleWatch app
		if let token = credentials.idToken, WCSession.isSupported() {

			print("Sending token to AppleWatch")
			let session = WCSession.default
			if session.isWatchAppInstalled {
				let userInfo = ["idToken":token]
				session.transferUserInfo(userInfo)
			}
		}

		// Store credentials in KeyChain
		return self.credentialsManager.store(credentials: credentials)
	}
}

func plistValues(bundle: Bundle) -> (clientId: String, domain: String)? {
	guard
		let path = bundle.path(forResource: "Auth0", ofType: "plist"),
		let values = NSDictionary(contentsOfFile: path) as? [String: Any]
		else {
			print("Missing Auth0.plist file with 'ClientId' and 'Domain' entries in main bundle!")
			return nil
	}

	guard
		let clientId = values["ClientId"] as? String,
		let domain = values["Domain"] as? String
		else {
			print("Auth0.plist file at \(path) is missing 'ClientId' and/or 'Domain' entries!")
			print("File currently has the following entries: \(values)")
			return nil
	}
	return (clientId: clientId, domain: domain)
}

