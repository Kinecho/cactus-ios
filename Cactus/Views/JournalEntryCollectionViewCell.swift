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
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var editTextView: UITextView!
    
    var journalEntry: JournalEntry?
    
    var sentPrompt: SentPrompt? {
        return self.journalEntry?.sentPrompt
    }
    var responses: [ReflectionResponse]? {
        return self.journalEntry?.responses
    }
    var prompt: ReflectionPrompt? {
        return self.journalEntry?.prompt
    }
    var promptContent: PromptContent? {
        return self.journalEntry?.promptContent
    }
    
    var isEditing = false
    var skeletonViewController = JournalEntrySkeletonViewController.loadFromNib()
//    var displaySkeleton: Bool = true {
//        didSet {
//            if self.displaySkeleton {
//                self.showSkeleton()
//            } else {
//                self.removeSkeleton()
//            }
//        }
//    }
    var displaySkeleton: Bool {
        return !(self.journalEntry?.loadingComplete ?? false)
    }
    let cornerRadius: CGFloat = 12
    @IBAction func moreButtonTapped(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Edit Reflection", style: .default) { _ in
            print("Edit reflection tapped")
            self.startEdit()
        })
        
        self.window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    func startEdit() {
        self.isEditing = true
        editTextView.isEditable = true
        editTextView.backgroundColor = .white
        self.editTextView.layer.borderWidth = 1
//        self.editTextView.isScrollEnabled = true
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
        
        editTextView.isEditable = false
//        self.editTextView.isScrollEnabled = false
        self.editTextView.layer.borderWidth = 0
        self.contentView.backgroundColor = .clear
        var response = self.responses?.first
        if response == nil, let promptId = self.sentPrompt?.promptId {
            response = ReflectionResponseService.sharedInstance.createReflectionResponse(promptId, promptQuestion: self.prompt?.question)
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
        self.contentView.backgroundColor = .white
//        self.editTextView.isScrollEnabled = false
        self.contentView.dismissKeyboard()
    }
    
    func showSkeleton() {
        self.skeletonViewController.view.frame = self.skeletonContainer.bounds
        self.skeletonViewController.view.layer.cornerRadius = self.cornerRadius
        self.skeletonViewController.view.clipsToBounds = true
        self.skeletonViewController.view.layoutSkeletonIfNeeded()
        
        self.skeletonContainer.isHidden = false
        self.skeletonContainer.addSubview(skeletonViewController.view)
        self.skeletonContainer.layoutSkeletonIfNeeded()
        self.skeletonContainer.layer.cornerRadius = self.cornerRadius
        self.skeletonContainer.clipsToBounds = true
        
        self.layer.cornerRadius = 12
        self.clipsToBounds = true
    }
    
    func removeSkeleton() {
        self.skeletonViewController.view.removeFromSuperview()
        self.skeletonContainer.isHidden = true
    }
    
    func updateView() {
        if !(self.journalEntry?.loadingComplete ?? false) {
            self.showSkeleton()
        } else {
            self.removeSkeleton()
            self.hideSkeleton()
        }
        
        self.contentView.isUserInteractionEnabled = true
//        var isLoading = false
        if let sentDate = self.sentPrompt?.firstSentAt {
            let dateString = FormatUtils.formatDate(sentDate)
            self.dateLabel.text = dateString
        } else {
            self.dateLabel.text = nil
        }
        
        if self.prompt != nil {
            self.questionLabel.text = self.prompt?.question ?? "Not Found"
        } else {
//            isLoading = true
        }
        
        if self.responses != nil {
           let responseText = FormatUtils.responseText(self.responses)
            self.editTextView.isHidden = false
            self.editTextView.text = responseText
        } else {
//            isLoading = true
            self.editTextView.isHidden = true
        }
        
        if self.prompt != nil && prompt?.promptContentEntryId != nil && self.promptContent == nil {
//            isLoading = true
        }
        
        if !(self.promptContent?.content.isEmpty ?? true) {
//            self.contentView.backgroundColor = CactusColor.lightGreen
        }
        
//        self.displaySkeleton = isLoading
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
        self.layer.cornerRadius = 12
    }
    
    func addShadows() {
        self.contentView.layer.cornerRadius = self.layer.cornerRadius
        self.contentView.layer.borderWidth = 0.0
        self.contentView.layer.borderColor = UIColor.clear.cgColor
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 10.0)
        self.layer.shadowRadius = 12.0
        self.layer.shadowOpacity = 0.15
        self.layer.masksToBounds = false
        
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        setNeedsLayout()
        layoutIfNeeded()
        
        let size = contentView.systemLayoutSizeFitting(layoutAttributes.size)
        frame.size.height = ceil(size.height)
        layoutAttributes.frame = frame
        
        return layoutAttributes
    }
}
