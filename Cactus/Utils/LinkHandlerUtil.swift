//
//  LinkHandlerUtil.swift
//  Cactus
//
//  Created by Neil Poulin on 11/14/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import Foundation

protocol HandleLinkResponse {
    var handled: Bool {get}
}

struct PromptContentHandler: HandleLinkResponse {
    let handled: Bool
    var promptContentEntryId: String?
    
    init(handled: Bool) {
        self.handled = handled
    }
}

class LinkHandlerUtil {
    static func getPath(_ link: String) -> String? {
        guard let url = URL(string: link) else {
            return nil
        }
        
        return url.path
    }
    
    static func getPathId(_ link: String, for name: String) -> String? {
        guard let url = URL(string: link) else {
            return nil
        }
       
        return url.getPathId(for: name)
    }
        
    static func handlePromptContent(_ url: URL) -> Bool {
        let entryId = url.getPathId(for: "prompts")
        
        if let entryId = entryId {
//            AppMainViewController.shared.loadPromptContent(promptContentEntryId: entryId, link: url.absoluteString)
            NavigationService.shared.loadPromptContent(promptContentEntryId: entryId, link: url.absoluteString)
            return true
        }
        
        return false
    }
    
    static func handleSharedResponse(_ url: URL) -> Bool {
        if let responseId = url.getPathId(for: "reflection") {
//            AppMainViewController.shared.loadSharedReflection(reflectionId: responseId, link: url.absoluteString)
            NavigationService.shared.loadSharedReflection(reflectionId: responseId, link: url.absoluteString)
            return true
        }
        return false
        
    }
    
    static func handleViewController(_ url: URL) -> Bool {
        if url.scheme?.contains(CactusConfig.customScheme) == false, url.host != "vc" {
            return false
        }
        let mode = url.getQueryParams()["mode"]
        let screenPath = url.lastPathComponent
        if let screenId = ScreenID(rawValue: screenPath) {
            let vc = screenId.getViewController()
            SessionStore.shared.addAuthAction { _ in
                if mode == "push" {
                    _ = AppMainViewController.shared.showScreen(vc)
                } else {
                    NavigationService.shared.present(vc, animated: true, completion: nil)
                }
            }
            return true
        }                
        return false
    }
    
    static func handleSignupUrl(_ url: URL) -> Bool {
        return url.path == "/signup" || url.path == "/login"
    }
}
