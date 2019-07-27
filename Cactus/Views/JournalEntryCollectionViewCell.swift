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
    
//    func willRend
    
    func updateView(){
        
        if let sentDate = self.sentPrompt?.firstSentAt {
            let dateString = FormatUtils.formatDate(sentDate)
            self.dateLabel.text = dateString
        } else {
            self.dateLabel.text = nil
        }
        
        self.questionLabel.text = sentPrompt?.id ?? nil
        self.responseLabel.text = "UserID = \(sentPrompt?.cactusMemberId ?? "None")\nEmail = \(sentPrompt?.memberEmail ?? "None")"
    }
}
