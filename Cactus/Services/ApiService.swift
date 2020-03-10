//
//  ApiService.swift
//  Cactus
//
//  Created by Neil Poulin on 10/24/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import Foundation

enum HttpMethod: String {
    case POST
    case GET
    case PUT
    case DELETE
    case OPTIONS
}

enum ApiPath: String {
    case loginEvent = "/signup/login-event"
    case sendMagicLink = "/signup/magic-link"
    case updateEmailSubscriberStatus = "/mailchimp/status"
    case sendSocialInvite = "/social/send-invite"
    case checkoutSubscriptionDetails = "/checkout/subscription-details"
    case appleCompletePurchase = "/apple/complete-purchase"
}

///A service for interacting with the Cactus JSON Api
public class ApiService {
    static let sharedInstance = ApiService()
    let apiDomain = CactusConfig.apiDomain
    let logger = Logger("ApiService")
    
    /**
     Turns an `Encodable` object into JSON data that can be sent via an XHR Request
     - Parameter object: The object to encode. Must adopt the `Encodable` protocol.
     - Returns: Optional Data object. If not present, the object was unable to encode
     */
    func serializeJSON<T: Encodable>(_ object: T) -> Data? {
        guard let jsonData = try? JSONEncoder().encode(object) else {
            self.logger.warn("Unable to get json data from object \(String(describing: object))")
            return nil
        }
        
        // JSONSerialization.
        let jsonString = String(data: jsonData, encoding: .utf8)
        self.logger.debug("Json string is: \(jsonString ?? "undefined")")
        return jsonData
    }
    
    /**
     Turn a JSON data payload into an object
     - Parameter data: Data object to be deserialized into a Swift object
     - Returns: Optional value of Genreic Type
     */
    func deserializeJSON<T: Decodable>(_ data: Data) -> T? {
        do {
            let decoder = JSONDecoder()
            let object = try decoder.decode(T.self, from: data)
            return object
        } catch {
            self.logger.error("Error decoding object \(error)")
            return nil
        }
    }
    
    /**
     Get the auth headers for the currently logged in user.  This method is asynchronous, so it takes a callback
     - Parameter completion: The completion callback. Arguments are a map of `[String:String]`
     */
    func getAuthHeaders(completion: @escaping ([String: String]) -> Void) {
        var headers: [String: String] = [:]
        
        CactusMemberService.sharedInstance.awaitCurrentUser { (currentUser) in
            self.logger.info("AWAIT CURRENT USER RETURNED. Current User: \(currentUser?.uid ?? "none")")
            if let currentUser = CactusMemberService.sharedInstance.currentUser {
                currentUser.getIDToken { (token, error) in
                    if let error = error {
                        self.logger.error("Faild to get auth token for current user", error)
                        completion([:])
                    }
                    
                    if let token = token {
                        headers["Authorization"] = "Bearer \(token)"
                    }
                    completion(headers)
                }
            } else {
                completion([:])
            }
        }
    }
    
    fileprivate func createRequest<T: Encodable>(_ apiPath: ApiPath,
                                                 method: HttpMethod,
                                                 authenticated: Bool=false,
                                                 body: T?,
                                                 completed: @escaping (URLRequest?, Any?) -> Void ) {
        self.createRequest(path: apiPath.rawValue, method: method, authenticated: authenticated, body: body, completed: completed)
    }
    
    /**
     Prepare an HTTP request. This will send to the configured environment's API Domain and can not be used for external requests
     - Parameter path: The path of the URL the request is sent to. Should start with a leading slash, like `/test/endpoint`. If no leading slash if provided, this method will add one.
     - Parameter method: The HTTP Method to be used
     - Parameter authenticated: Boolean value if the request should be authenticated with the currently logged in user
     - Parameter body: Optional. An object to be serialized into json and sent as the request's body.
     - Parameter completed: Function that is called when the request has finished being prepared. Arguments are the request and any error
     */
    fileprivate func createRequest<T: Encodable>(path: String,
                                                 method: HttpMethod,
                                                 authenticated: Bool=false,
                                                 body: T?,
                                                 completed: @escaping (URLRequest?, Any?) -> Void ) {
        var json: Data?
        
        if body != nil {
            json = self.serializeJSON(body)
            if json == nil {
                let errorMessage = "Unable to get json data from body object \(String(describing: body))"
                self.logger.warn(errorMessage)
                completed(nil, errorMessage)
                return
            }
        }
        
        var path = path
        if !path.starts(with: "/") {
            path = "/\(path)"
        }
        let absoluteUrl = "\(self.apiDomain)\(path)"
        self.logger.info("Sending message to url \(absoluteUrl)")
        guard let url = URL(string: absoluteUrl) else {
            let errorMessage = "Unable to create a URL for for absoluteUrl \(absoluteUrl)"
            self.logger.warn(errorMessage)
            completed(nil, errorMessage)
            return
        }
        
        var request = URLRequest(url: url)
        var headers = request.allHTTPHeaderFields ?? [:]
        headers["Content-Type"] = "application/json"
        request.allHTTPHeaderFields = headers
        request.httpMethod = method.rawValue
        request.httpBody = json
        
        if authenticated {
            getAuthHeaders { (authHeaders) in
                headers = headers.merging(authHeaders) { (_, new) in new }
                request.allHTTPHeaderFields = headers
                completed(request, nil)
            }
        } else {
            completed(request, nil)
        }
    }
    
    fileprivate func createEmptyRequest(_ apiPath: ApiPath,
                                        method: HttpMethod,
                                        authenticated: Bool=false,
                                        completed: @escaping (URLRequest?, Any?) -> Void ) {
        self.createEmptyRequest(path: apiPath.rawValue, method: method, authenticated: authenticated, completed: completed)
    }
    
    /**
     Prepare an HTTP request. This will send to the configured environment's API Domain and can not be used for external requests
     - Parameter path: The path of the URL the request is sent to. Should start with a leading slash, like `/test/endpoint`. If no leading slash if provided, this method will add one.
     - Parameter method: The HTTP Method to be used
     - Parameter authenticated: Boolean value if the request should be authenticated with the currently logged in user
     - Parameter body: Optional. An object to be serialized into json and sent as the request's body.
     - Parameter completed: Function that is called when the request has finished being prepared. Arguments are the request and any error
     */
    fileprivate func createEmptyRequest(path: String,
                                        method: HttpMethod,
                                        authenticated: Bool=false,
                                        completed: @escaping (URLRequest?, Any?) -> Void ) {
        
        var path = path
        if !path.starts(with: "/") {
            path = "/\(path)"
        }
        let absoluteUrl = "\(self.apiDomain)\(path)"
        self.logger.info("Sending message to url \(absoluteUrl)")
        guard let url = URL(string: absoluteUrl) else {
            let errorMessage = "Unable to create a URL for for absoluteUrl \(absoluteUrl)"
            self.logger.warn(errorMessage)
            completed(nil, errorMessage)
            return
        }
        
        var request = URLRequest(url: url)
        var headers = request.allHTTPHeaderFields ?? [:]
        headers["Content-Type"] = "application/json"
        request.allHTTPHeaderFields = headers
        request.httpMethod = method.rawValue
        
        if authenticated {
            getAuthHeaders { (authHeaders) in
                headers = headers.merging(authHeaders) { (_, new) in new }
                request.allHTTPHeaderFields = headers
                completed(request, nil)
            }
        } else {
            completed(request, nil)
        }
    }
    
    /**
     Sends a magic link to the specified email
     - Parameter magicLinkRequest: The body of the request to send to the API.
     - Parameter completed: The callback to be executed once the API request comes back.
     */
    func sendMagicLink(_ magicLinkRequest: MagicLinkRequest,
                       onTask: ((URLSessionDataTask) -> Void)?=nil,
                       completed: @escaping (MagicLinkResponse) -> Void ) {
        self.createRequest(ApiPath.sendMagicLink, method: .POST, body: magicLinkRequest) { request, setupError in
            //handle any error setting up the request
            guard let request = request, setupError == nil else {
                let errorMessage = setupError as? String
                completed(MagicLinkResponse(email: magicLinkRequest.email, success: false, message: "Unable to send magic link. The request was invalid.", error: errorMessage))
                return
            }
            //Start the HTTP request
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                //handle the error
                if let response = response as? HTTPURLResponse {
                    self.logger.info("Send Magic Link Event response status \(response.statusCode)")
                }
                
                guard let data = data, error == nil else {
                    let message = error?.localizedDescription ?? "Unable to send magic link."
                    self.logger.info("magic link error message...? \(message) ")
                    let errorResponse = MagicLinkResponse(email: magicLinkRequest.email, success: false, message: message, error: message)
                    completed(errorResponse)
                    return
                }
                
                if let magicLinkResponse: MagicLinkResponse = self.deserializeJSON(data) {
                    self.logger.info("Successfully processed magic link response \(String(describing: magicLinkResponse))")
                    completed(magicLinkResponse)
                    return
                } else {
                    self.logger.error("Failed to decode Magic Link Response")
                    let message = "Something went wrong while sending your Magic Link email. Please try again later"
                    completed(MagicLinkResponse(email: magicLinkRequest.email, success: false, message: message, error: message))
                    return
                }
            }
            onTask?(task)
            task.resume()
        }
    }
    
    func post<R: Codable, T: Codable>(
        path: ApiPath,
        body: R,
        responseType: T.Type,
        authenticated: Bool = true,
        onTask: ((URLSessionDataTask) -> Void)?=nil,
        _ onCompleted: ((T?, Any?) -> Void)?=nil ) {
        self.logger.debug("Sending POST request to \(path)")
        self.createRequest(path, method: .POST, authenticated: authenticated, body: body) { (request, error) in
            guard let request = request, error == nil else {
                onCompleted?(nil, error)
                return
            }
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                let statusCode = (response as? HTTPURLResponse)?.statusCode
                self.logger.info("POST to \(path) returned status \(statusCode ?? -1) with data \(String(describing: data))")
                if let error = error {
                    self.logger.error("Error sending POST to \(path)", error)
                    onCompleted?(nil, error)
                    return
                }
                if let data = data {
                    let responseBody: T? = self.deserializeJSON(data)
                    onCompleted?(responseBody, error)
                    return
                } else {
                    onCompleted?(nil, nil)
                    return
                }                
            }
            onTask?(task)
            task.resume()
        }
    }
    
    func get<T: Codable>(
        path: ApiPath,
        responseType: T.Type,
        authenticated: Bool = true,
        onTask: ((URLSessionDataTask) -> Void)?=nil,
        _ onCompleted: ((T?, Any?) -> Void)?=nil ) {
        self.logger.debug("Sending GET request to \(path)")
        self.createEmptyRequest(path, method: .GET, authenticated: authenticated) { (request, error) in
            guard let request = request, error == nil else {
                onCompleted?(nil, error)
                return
            }
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                let statusCode = (response as? HTTPURLResponse)?.statusCode
                self.logger.info("GET to \(path) returned status \(statusCode ?? -1) with data \(String(describing: data))")
                if let error = error {
                    self.logger.error("Error sending GET to \(path)", error)
                    onCompleted?(nil, error)
                    return
                }
                if let data = data {
                    let responseBody: T? = self.deserializeJSON(data)
                    self.logger.info("response body \(String(describing: data))")
                    onCompleted?(responseBody, error)
                    return
                } else {
                    onCompleted?(nil, nil)
                    return
                }
            }
            onTask?(task)
            task.resume()
        }
    }
    
    /**
     When login is successfully performed, send data to the API so we perform post-login actions on the backend
     - Parameter loginEvent: The login event object
     - Parameter onTask: A callback that returns the URLSessionDataTask. Useful if you need to be able to cancel a request
     - Parameter completed: A completion callback fired when the request finishes. Passes an optional Error object
     */
    func sendLoginEvent(
        _ loginEvent: LoginEvent,
        onTask: ((URLSessionDataTask) -> Void)?=nil,
        completed: ((_ error: Any?) -> Void)?=nil) {
        self.createRequest(ApiPath.loginEvent, method: .POST, authenticated: true, body: loginEvent) { (request, error) in
            guard let request = request, error == nil else {
                completed?(error)
                return
            }
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                self.logger.info("Login Event Data \(String(describing: data))")
                if let response = response as? HTTPURLResponse {
                    self.logger.info("Login Event Response status \(response.statusCode)")
                }
                if let error = error {
                    self.logger.error("Login Event API returned an error", error)
                } else {
                    self.logger.info("Login Event submitted successfully")
                }
                completed?(error)
            }
            onTask?(task)
            task.resume()
        }
    }
    
    func updateEmailSubscriptionStatus(_ payload: EmailNotificationStatusRequest,
                                       onTask: ((URLSessionDataTask) -> Void)? = nil,
                                       completed: ((_ updateResponse: EmailNotificationStatusResponse) -> Void)? = nil
    ) {
        var updateResponse = EmailNotificationStatusResponse()
        let email = payload.email
        self.createRequest(ApiPath.updateEmailSubscriberStatus,
                           method: .PUT,
                           authenticated: true,
                           body: payload) { (request, error) in
            guard let request = request, error == nil else {
                updateResponse.error = EmailNotificationStatusResponseError("Unable to update your email settings. Please try again later.")
                updateResponse.success = false
                completed?(updateResponse)
                return
            }
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                self.logger.info("Update Email Subscription Status Event Data \(String(describing: data))")
                if let error = error {
                    self.logger.error("Update Email Subscription Status Event API returned an error", error)
                    updateResponse.error = EmailNotificationStatusResponseError("Unable to update your email settings at this time. Please try again later.")
                    updateResponse.success = false
                    completed?(updateResponse)
                    return
                }
                self.logger.info("Update Email Subscription Status returned successfully")
                if let response = response as? HTTPURLResponse {
                    self.logger.info("Login Event Response status \(response.statusCode)")
                    if response.statusCode > 299 || response.statusCode < 200 {
                        updateResponse.error = EmailNotificationStatusResponseError("An unexpected error occurred while attempting to update your email settings. Please try again later.")
                        updateResponse.success = false
                        self.logger.error("Failed to update email status for member \(email). Response status \(response.statusCode)")
                        completed?(updateResponse)
                        return
                    }
                    guard let data = data,
                        let body: EmailNotificationStatusResponse = self.deserializeJSON(data) else {
                        updateResponse.success = true //true because it was a successful response code

                        self.logger.warn("[Update Email settings] Unable to deserialize the response", functionName: #function, line: #line)
                        completed?(updateResponse)
                        return
                    }
                    updateResponse.success = body.success
                    updateResponse.error = body.error
                  
                    completed?(updateResponse)
                    return
                }
                updateResponse.success = false
                updateResponse.error = EmailNotificationStatusResponseError("An unexpected error occurred while attempting to update your email settings. Please try again later.")
                completed?(updateResponse)
            }
            onTask?(task)
            task.resume()
        }
    }
}
