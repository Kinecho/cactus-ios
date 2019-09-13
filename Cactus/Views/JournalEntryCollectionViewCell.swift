//
//  JournalEntryCollectionViewCell.swift
//  Cactus
//
//  Created by Neil Poulin on 7/26/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import UIKit

@IBDesignable
class JournalEntryCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var responseLabel: UILabel!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var editTextView: UITextView!
        
    var sentPrompt: SentPrompt?
    var responses: [ReflectionResponse]?
    var prompt: ReflectionPrompt?
    
    var isEditing = false
    
    @IBAction func moreButtonTapped(_ sender: Any) {
        
//        let title = "Log Out?"
        
//        var  message = "Are you sure you want to log out?"
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Edit Reflection", style: .default) { _ in
            print("Edit reflection tapped")
            self.startEdit()
        })
        
        self.window?.rootViewController?.present(alert, animated: true, completion: nil)

    }
    
    @IBInspectable var borderRadius: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set {
            self.layer.cornerRadius = newValue
        }
    }
    
    func startEdit() {
        self.isEditing = true
        
        editTextView.text = responseLabel.text
        
        editTextView.isHidden = false
        responseLabel.isHidden = true
//        editTextView.isFocused = true
        
        let bar = UIToolbar()
        let save = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(self.saveEdit))
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancel = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.cancelEdit))
        bar.items = [cancel, spacer, save]
        bar.sizeToFit()
        editTextView.inputAccessoryView = bar
        editTextView.becomeFirstResponder()
        
        self.contentView.backgroundColor = CactusColor.pink
        
    }
    
    @objc func saveEdit(_ sender: Any?) {
        self.isEditing = false
        
        self.contentView.dismissKeyboard()
        
        responseLabel.text = editTextView.text
        editTextView.isHidden = true
        responseLabel.isHidden = false
        self.contentView.backgroundColor = .clear
        var response = self.responses?.first
        if response == nil, let promptId = self.sentPrompt?.promptId {
            response = ReflectionResponseService.sharedInstance.createReflectionResponse(promptId, promptQuestion: self.prompt?.question)
//            response = ReflectionResponse()
//            response?.promptId = self.sentPrompt?.promptId
//            response?.createdAt = Date()
//            response?.deleted = false
//            response?.responseMedium = .JOURNAL_IOS
        }
        
        response?.content.text = self.editTextView.text
        
        self.responses?.forEach { r in
            if r.id != response?.id {
                ReflectionResponseService.sharedInstance.delete(r, { (error) in
                    if let error = error {
                        print("failed to delete reflection response \(r.id ?? "id unknown")", error)
                    } else {
                        print("Successfully deleted reflection response")
                    }
                })
            }
        }
        
        guard let toSave = response else {
            print("No response found while trying to save... exiting")
            return
        }
        ReflectionResponseService.sharedInstance.save(toSave) { (saved, _) in
            print("Saved the response! \(saved?.id ?? "no id found")")
        }
        
    }
    
    @objc func cancelEdit(_ sender: Any?) {
        self.isEditing = false
        editTextView.isHidden = true
        responseLabel.isHidden = false
        self.contentView.backgroundColor = .white
        self.contentView.dismissKeyboard()
        
    }
    
    func updateView() {
        
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
    
    override func prepareForInterfaceBuilder() {
        self.layoutSubviews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.editTextView.layer.borderColor = CactusColor.borderLight.cgColor
        self.editTextView.layer.borderWidth = 1
        self.editTextView.layer.cornerRadius = 6
        self.layer.borderColor = CactusColor.borderLight.cgColor
        self.layer.borderWidth = 1

    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
