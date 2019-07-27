//
//  JournalEntryDataLoadOperation.swift
//  Cactus
//
//  Created by Neil Poulin on 7/26/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import Foundation

class JournalEntryDataLoadOperation:Operation {
    var sentPrompt:SentPrompt!
    var response: ReflectionResponse?
    var prompt: ReflectionPrompt?
    var onData: ((ReflectionPrompt?, ReflectionResponse? ) -> Void)?
    
    init(_ sentPrompt:SentPrompt){
        self.sentPrompt = sentPrompt
    }
    
    override func main() {
        if isCancelled {return}
        
        
        if let promptId = sentPrompt.promptId {
            
        }
    }
}
