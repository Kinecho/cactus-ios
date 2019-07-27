//
//  JournalEntryCollectionViewCell.swift
//  Cactus
//
//  Created by Neil Poulin on 7/26/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import UIKit

class JournalEntryCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var responseLabel: UILabel!
    @IBOutlet weak var moreButton: UIButton!
    
    var sentPrompt:SentPrompt?;
    var responses: [ReflectionResponse]?
    var prompt: ReflectionPrompt?
    
//    func willRend
    
    func updateView(){
        
        if let sentDate = self.sentPrompt?.firstSentAt {
            let dateString = FormatUtils.formatDate(sentDate)
            self.dateLabel.text = dateString
        } else {
            self.dateLabel.text = nil
        }
        
        self.questionLabel.text = self.prompt?.question ?? "Not Found"
        
        let responseText =  self.responses?.map {$0.content.text ?? ""}.joined(separator: "\n\n")
        
        self.responseLabel.text = responseText
    }
}
