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
        if let currentUser = CactusMemberService.sharedInstance.currentUser {
            currentUser.getIDToken { (token, error) in
                if let error = error {
                    self.logger.error("Faild to get auth token for current user", error)
                }
                
                if let token = token {
                    headers["Authorization"] = "Bearer \(token)"
                }
                completion(headers)
            }
        }
    }
    
    fileprivate func createRequest<T: Encodable>(_ apiPath: ApiPath,
                                                 method: HttpMethod,
                                                 authenticated: Bool=false, body: T?,
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
                                                 authenticated: Bool=false, body: T?,
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
    
    /**
     When login is successfully performed, send data to the API so we perform post-login actions on the backend
        - Parameter loginEvent: The login event object
        - Parameter onTask: A callback that returns the URLSessionDataTask. Useful if you need to be able to cancel a request
        - Parameter completed: A completion callback fired when the request finishes. Passes an optional Error object
     */
    func sendLoginEvent(_ loginEvent: LoginEvent,
                        onTask: ((URLSessionDataTask) -> Void)?=nil,
                        ///on completed handler
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
}
