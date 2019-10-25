//
//  ApiService.swift
//  Cactus
//
//  Created by Neil Poulin on 10/24/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import Foundation

public class ApiService {
    static let sharedInstance = ApiService()
    let apiDomain = CactusConfig.apiDomain
    
    func getJsonData<T: Encodable>(_ object: T) -> Data? {
        guard let jsonData = try? JSONEncoder().encode(object) else {
            print("Unable to get json data from object \(String(describing: object))")
            return nil
        }
        
//        JSONSerialization.
        let jsonString = String(data: jsonData, encoding: .utf8);
        print("Json string is: \(jsonString ?? "undefined")")
        return jsonData
    }
    
    func sendMagicLink(_ magicLinkRequest: MagicLinkRequest, completed: @escaping (MagicLinkResponse) -> Void ) {
        guard let json = self.getJsonData(magicLinkRequest) else {
            print("Unable to get json data from magic link request")
            completed(MagicLinkResponse(email: magicLinkRequest.email, success: false, message: "Unable to serialize request object"))
            return
        }
        
        guard let url = URL(string: "\(self.apiDomain)/signup/magic-link") else {
            print("Unable to get url for magic link endpoint")
            completed(MagicLinkResponse(email: magicLinkRequest.email, success: false, message: "Unable to create URL for the request"))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpBody = json
        var headers = request.allHTTPHeaderFields ?? [:]
        headers["Content-Type"] = "application/json"
        request.allHTTPHeaderFields = headers
        request.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                let message = error?.localizedDescription ?? "No Data returned"
                print(message)
                completed(MagicLinkResponse(email: magicLinkRequest.email, success: false, message: message))
                return
            }
            do {
                let decoder = JSONDecoder()
                let magicLinkResponse = try decoder.decode(MagicLinkResponse.self, from: data)
                completed(magicLinkResponse)
                return
            } catch {
                print("Error decoding response \(error)")
                completed(MagicLinkResponse(email: magicLinkRequest.email, success: false, message: "Failed to decode the response"))
                return
            }
            
            
        }
        task.resume()
    }
}
