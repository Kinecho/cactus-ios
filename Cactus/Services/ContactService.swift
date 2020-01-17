//
//  ContactService.swift
//  Cactus
//
//  Created by Neil Poulin on 1/15/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import Foundation
import ContactsUI

struct SocialContact {
    
    private var _email: String?
    
    var email: String? {
        get {
            self._email
        }
        set {
            self._email = newValue?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    var firstName: String?
    var lastName: String?
    var phoneNumber: String?
    
    var avatarImage: UIImage?
    
    var avatarImageData: Data? {
        set {
            if let data = newValue {
                self.avatarImage = UIImage.init(data: data)
            } else {
                self.avatarImage = nil
            }            
        }
        get {
            self.avatarImage?.imageData
        }
    }
    
    var fullName: String? {
        guard firstName != nil || lastName != nil else {
            return nil
        }
        
        return "\(firstName ?? "") \(lastName ?? "")".trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
