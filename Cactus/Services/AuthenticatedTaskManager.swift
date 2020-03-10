//
//  AuthenticatedTaskManager.swift
//  Cactus
//
//  Created by Neil Poulin on 3/9/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import Foundation

class AuthenticatedTaskManager: AuthenticatedTaskDelegate {
    static var shared = AuthenticatedTaskManager()
    var queue: [AuthenticatedTask] = []
    let logger = Logger("AuthenticatedTaskManager")
    func addTask(_ task: AuthenticatedTask) {
        self.queue.append(task)
        task.delegate = self
        task.start()
        
    }
    
    func onCompleted(task: AuthenticatedTask) {
        self.logger.info("Auth task has finished. Removing from queue. There are \(self.queue.count) items in the queue")
        self.queue.removeAll { (t) -> Bool in
            return t === task
        }
        self.logger.info("There are \(self.queue.count) items left in the queue")
    }
}
