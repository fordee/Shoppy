//
//  WebService.swift
//  Shoppy
//
//  Created by John Forde on 17/2/18.
//  Copyright © 2018 4DWare. All rights reserved.
//

import Foundation

enum WebServiceError: Error {
	case badResponse
	case noResponse
	case other
}

enum HttpMethod<T: Encodable> {
	case get
	case post(data: T)
	case put(data: T)
	case delete(data: T)
}

extension HttpMethod {
	var methodString: String {
		switch self {
		case .get:
			return "GET"
		case .post:
			return "POST"
		case .put:
			return "PUT"
		case .delete:
			return "DELETE"
		}
	}
}

class WebService {
	let session: URLSession
	var rootURL: URL

	init (rootURL:URL) {
		self.rootURL = rootURL;
		let configuration = URLSessionConfiguration.default
		session = URLSession(configuration: configuration)
	}

	func setRootURL(rootURL: URL) {
		self.rootURL = rootURL
	}

	// MARK: - ****** Request Helpers ******
	internal func requestWithURLString<T>(_ string: String, method: HttpMethod<T>) -> URLRequest? {
		let deleteString: String
		switch method {
		case .delete(let itemData):
			deleteString = itemData as! String
		default:
			deleteString = ""
			break
		}

		if let url = URL(string: string + deleteString, relativeTo: rootURL) {
			var urlRequest = URLRequest(url: url)
			urlRequest.httpMethod = method.methodString
			urlRequest.allHTTPHeaderFields = [
				"Accept" : "application/json",
				"Content-Type" : "application/json"
			]
			let encoder = JSONEncoder()
			switch method {
			case .get:
				break
			case .post(let itemData):
				do {
					print("data: \(itemData)")
					urlRequest.httpBody = try encoder.encode(itemData)
				} catch let encodeError as NSError {
					print("Encoder Error: \(encodeError.localizedDescription)")
				}
			case .put(let itemData):
				do {
					print("data: \(itemData)")
					urlRequest.httpBody = try encoder.encode(itemData)
				} catch let encodeError as NSError {
					print("Encoder Error: \(encodeError.localizedDescription)")
				}
			case .delete:
				break
			}

			return urlRequest
		}
		return nil
	}

	internal func executeRequest<ResponseType: Decodable, T: Encodable>(_ requestPath:String, method: HttpMethod<T> = .get, completion: @escaping (_ response: ResponseType?, _ error: NSError?) -> Void) {
		print("Executing Request With Path: \(requestPath)")
		if let request = requestWithURLString(requestPath, method: method) {
			// Create the task
			let task = session.dataTask(with: request) { data, response, error in

				if error != nil {
					completion(nil, error as NSError?)
					return
				}

				// Check to see if there was an HTTP Error
				let cleanResponse = self.checkResponseForErrors(response)
				if let errorCode = cleanResponse.errorCode {
					print("An error occurred: \(errorCode)")
					completion(nil, error as NSError?)
					return
				}

				if method.methodString == "GET" {
					// Decode the response
					let decoder = JSONDecoder()
					guard let data = data else {
						print("No response data")
						completion(nil, error as NSError?)
						return
					}

					let response: ResponseType
					do {
						response = try decoder.decode(ResponseType.self, from: data)
					} catch (let error) {
						print("Parsing Issues")
						completion(nil, error as NSError?)
						return
					}

					// Things went well, call the completion handler
					completion(response, nil)
				}
			}
			task.resume()

		} else {
			// It was a bad URL, so just fire an error
			let error = NSError(domain:NSURLErrorDomain,
													code:NSURLErrorBadURL,
													userInfo:[ NSLocalizedDescriptionKey : "There was a problem creating the request URL:\n\(requestPath)"] )
			completion(nil, error)
		}
	}

	func checkResponseForErrors(_ response: URLResponse?) -> (httpResponse: HTTPURLResponse?, errorCode: WebServiceError?) {
		guard response != nil else {
			return (nil, WebServiceError.noResponse)
		}

		guard let httpResponse = response as? HTTPURLResponse else {
			return (nil, WebServiceError.badResponse)
		}

		let statusCode = httpResponse.statusCode
		guard statusCode >= 200 && statusCode <= 299 else {
			return (nil, WebServiceError.other)
		}

		return (httpResponse, nil)
	}



}
