//
//  JournalEntryCollectionViewCell.swift
//  Cactus
//
//  Created by Neil Poulin on 7/26/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import UIKit
import SkeletonView

@IBDesignable
class JournalEntryCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var skeletonContainer: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
//    @IBOutlet weak var responseLabel: UILabel!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var editTextView: UITextView!
    var sentPrompt: SentPrompt?
    var responses: [ReflectionResponse]?
    var prompt: ReflectionPrompt?
    var promptContent: PromptContent?
    var isEditing = false
    var skeletonViewController = JournalEntrySkeletonViewController.loadFromNib()
    var displaySkeleton: Bool = true {
        didSet {
            if self.displaySkeleton {
                self.showSkeleton()
            } else {
                self.removeSkeleton()
            }
        }
    }
    let cornerRadius: CGFloat = 12
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
        
//        editTextView.text = responseLabel.text
        editTextView.isEditable = true
        editTextView.backgroundColor = .white
        self.editTextView.layer.borderWidth = 1
//        editTextView.isHidden = false
//        responseLabel.isHidden = true
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
        
//        responseLabel.text = editTextView.text
//        editTextView.isHidden = true
        editTextView.isEditable = false
        self.editTextView.layer.borderWidth = 0
//        responseLabel.isHidden = false
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
        editTextView.isEditable = false
        editTextView.backgroundColor = .clear
        self.editTextView.layer.borderWidth = 0
//        editTextView.isHidden = true
//        responseLabel.isHidden = false
        self.contentView.backgroundColor = .white
        self.contentView.dismissKeyboard()
        
    }
    
    func showSkeleton() {
        
        self.skeletonViewController.view.frame = self.skeletonContainer.bounds
        self.skeletonViewController.view.layer.cornerRadius = self.cornerRadius
        self.skeletonContainer.isHidden = false
        self.skeletonContainer.addSubview(skeletonViewController.view)
        self.skeletonContainer.layoutSkeletonIfNeeded()
        self.skeletonViewController.view.layoutSkeletonIfNeeded()
//        let left = skeletonViewController.view.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0)
//        let right = skeletonViewController.view.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0)
//        let top = skeletonViewController.view.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0)
//        let bottom = skeletonViewController.view.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0)
//
//        NSLayoutConstraint.activate([left, right, top, bottom])
        
//        self.didAddSubview(skeletonViewController.view)
//        self.skeletonViewController.view.layoutSubviews()
//        self.skeletonViewController.view.layoutSkeletonIfNeeded()
    }
    
    func removeSkeleton() {
//        self.willRemoveSubview(self.skeletonViewController.view)
//        self.contentView.willRemoveSubview(self.skeletonViewController.view)
        self.skeletonViewController.view.removeFromSuperview()
        self.skeletonContainer.isHidden = true
//        self.skeletonContainer.removeFromSuperview()
    }
    
    func updateView() {
        self.contentView.isUserInteractionEnabled = true
        var isLoading = false
        if let sentDate = self.sentPrompt?.firstSentAt {
            let dateString = FormatUtils.formatDate(sentDate)
            self.dateLabel.text = dateString
        } else {
            self.dateLabel.text = nil
        }
        
        if self.prompt != nil {
            self.questionLabel.text = self.prompt?.question ?? "Not Found"
        } else {
            isLoading = true
        }
        
        if self.responses != nil {
            let responseText =  self.responses?.map {$0.content.text ?? ""}.joined(separator: "\n\n")
            self.editTextView.text = responseText
        } else {
//            isLoading = true
        }
        
        if self.prompt != nil && prompt?.promptContentEntryId != nil && self.promptContent == nil {
            isLoading = true
        }
        
        if !(self.promptContent?.content.isEmpty ?? true) {
//            self.contentView.backgroundColor = CactusColor.lightGreen
        }
        
        self.displaySkeleton = isLoading
    }
    
    override func prepareForInterfaceBuilder() {
        self.layoutSubviews()
        self.addShadows()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if self.editTextView != nil {
            self.editTextView.layer.borderColor = CactusColor.borderLight.cgColor
            self.editTextView.layer.borderWidth = 0
            self.editTextView.layer.cornerRadius = self.cornerRadius
        }
        
        self.layer.borderColor = UIColor.clear.cgColor
        self.layer.borderWidth = 0
        self.skeletonViewController.view.layoutSubviews()
        self.skeletonViewController.view.layoutSkeletonIfNeeded()
        self.addShadows()
        
    }
    
    func addShadows() {
//        guard !self.hasShadows else {
//            return
//        }
        //        self.layer.shadowColor = UIColor.black.cgColor
        //        self.layer.shadowOpacity = 1
        //        self.layer.shadowOffset = .zero
        //        self.layer.shadowRadius = 10
        //        self.layer.masksToBounds = false
        self.contentView.layer.cornerRadius = self.layer.cornerRadius
//        self.contentView.layer.cornerRadius = 2.0
        self.contentView.layer.borderWidth = 0.0
        self.contentView.layer.borderColor = UIColor.clear.cgColor
        //        self.contentView.layer.masksToBounds = true
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 10.0)
        self.layer.shadowRadius = 12.0
        self.layer.shadowOpacity = 0.15
        self.layer.masksToBounds = false
        
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        self.addShadows()
        
    }
}
