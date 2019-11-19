//
//  AppSettingsService.swift
//  Cactus
//
//  Created by Neil Poulin on 10/31/19.
//  Copyright © 2019 Cactus. All rights reserved.
//
import Foundation
import Firebase
import FirebaseFirestore

class AppSettingsService {
    let flamelinkService: FlamelinkService
    let schema = FlamelinkSchema.appSettings_ios
    var currentSettings: AppSettings?
    fileprivate var settingsObserver: ListenerRegistration?
    
    static let sharedInstance = AppSettingsService()
    
    private init() {
        self.flamelinkService = FlamelinkService.sharedInstance
        self.settingsObserver = self.observeSettings { (settings, error) in
            if let error = error {
                print("Failed to observe settings", error)
            }
            self.currentSettings = settings
        }
    }
    
    deinit {
        self.settingsObserver?.remove()
    }
    
    func observeSettings(_ onData: @escaping (AppSettings?, Any?) -> Void) -> ListenerRegistration {
        let query = flamelinkService.getQuery(self.schema)
        return self.flamelinkService.observeQuery(query) { (settings: [AppSettings]?, error) in
            if let error = error {
                print("Error fetching settings", error)
            }
            onData(settings?.first, error)
        }
    }
    
    func getSettings(_ onData: @escaping (AppSettings?, Any?) -> Void) {
        let query = flamelinkService.getQuery(self.schema)
        self.flamelinkService.getFirst(query) { (settings: AppSettings?, error) in
            if let error = error {
                print("Error fetching settings", error)
            }
            onData(settings, error)
        }
    }
}
