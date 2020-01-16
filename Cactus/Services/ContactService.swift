//
//  ContactService.swift
//  Cactus
//
//  Created by Neil Poulin on 1/15/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import Foundation
import ContactsUI

struct NativeContact {
    
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
    
    var fullName: String? {
        guard firstName != nil || lastName != nil else {
            return nil
        }
        
        return "\(firstName ?? "") \(lastName ?? "")".trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

class ContactService: NSObject, CNContactPickerDelegate {
    static var sharedInstance = ContactService()
    
//    func getContact(_ vc: UIViewController, limit: Int = 1, _ onData: @escaping ([NativeContact]) -> Void) {
//
//        onData([])
//    }
    
//    func contactPicker(_ picker: CNContactPickerViewController,
//                       didSelect contacts: [CNContact]) {
//      let newFriends = contacts.compactMap { Friend(contact: $0) }
//      for friend in newFriends {
//        if !friendsList.contains(friend) {
//          friendsList.append(friend)
//        }
//      }
//      tableView.reloadData()
//    }
}
