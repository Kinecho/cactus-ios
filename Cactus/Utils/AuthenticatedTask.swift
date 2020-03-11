//
//  AuthenticatedTask.swift
//  Cactus
//
//  Created by Neil Poulin on 3/9/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import Foundation
import FirebaseAuth

protocol AuthenticatedTaskDelegate: class {
    func onCompleted(task: AuthenticatedTask)
}

///Callback function to handle task
typealias AuthTaskHandler = (_ member: CactusMember?, _ user: User?, _ onCompleted: @escaping () -> Void) -> Void

class AuthenticatedTask {
    private var onAuth: AuthTaskHandler?
    private var memberUnsubscriber: Unsubscriber?
    private let logger = Logger("AuthenticatedTask")
    weak var delegate: AuthenticatedTaskDelegate?
    
    init(onAuth: @escaping AuthTaskHandler) {
        self.onAuth = onAuth
    }
    
    func start() {
        self.memberUnsubscriber = CactusMemberService.sharedInstance.observeCurrentMember { (member, error, user) in
            self.memberUnsubscriber?()
            if let error = error {
                self.logger.error("Failed to get the user from auth", error)
            }
            self.onAuth?(member, user) {
                self.logger.info("Task has completed")
                self.delegate?.onCompleted(task: self)
            }
        }
    }
    
}
