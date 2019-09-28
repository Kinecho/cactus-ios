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
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var responseTextView: UITextView!
    var cellWidthConstraint: NSLayoutConstraint?
    
    @IBOutlet weak var borderView: UIView!
    
    var journalEntry: JournalEntry?
    var responseTextViewHeightConstraint: NSLayoutConstraint?
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
        responseTextView.isEditable = true
        responseTextView.backgroundColor = .white
        self.responseTextView.layer.borderWidth = 1
//        self.editTextView.isScrollEnabled = true
        let bar = UIToolbar()
        let save = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(self.saveEdit))
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancel = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.cancelEdit))
        bar.items = [cancel, spacer, save]
        bar.sizeToFit()
        
        responseTextView.inputAccessoryView = bar
        responseTextView.becomeFirstResponder()
        
        self.contentView.backgroundColor = CactusColor.pink
        
    }
    
    @objc func saveEdit(_ sender: Any?) {
        self.isEditing = false
        self.contentView.dismissKeyboard()
        
        responseTextView.isEditable = false
//        self.editTextView.isScrollEnabled = false
        self.responseTextView.layer.borderWidth = 0
        self.contentView.backgroundColor = .clear
        var response = self.responses?.first
        if response == nil, let promptId = self.sentPrompt?.promptId {
            response = ReflectionResponseService.sharedInstance.createReflectionResponse(promptId, promptQuestion: self.prompt?.question)
        }
        
        response?.content.text = self.responseTextView.text
        
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
        responseTextView.isEditable = false
        responseTextView.backgroundColor = .clear
        self.responseTextView.layer.borderWidth = 0
        self.contentView.backgroundColor = .white
//        self.editTextView.isScrollEnabled = false
        self.contentView.dismissKeyboard()
    }
    
    func removeResponseView() {
//        self.responseTextViewHeightConstraint = self.responseTextView.heightAnchor.constraint(equalToConstant: 0)
        self.responseTextViewHeightConstraint?.constant = 0
        self.responseTextViewHeightConstraint?.isActive = true
        self.responseTextView.isHidden = true
        self.borderView.isHidden = true
    }
    
    func showResponseView() {
        self.responseTextView.isHidden = false
        self.borderView.isHidden = false
    }
    
    func addSkeletons() {
        if self.journalEntry?.responsesLoaded == true {
            self.showResponseView()
//            self.responseTextViewHeightConstraint = self.responseTextView.heightAnchor.constraint(equalToConstant: 90)
            self.responseTextViewHeightConstraint?.constant = 90
            self.responseTextViewHeightConstraint?.isActive = true
            self.responseTextView.showAnimatedGradientSkeleton()
        } else {
            self.responseTextView.hideSkeleton()
            self.responseTextViewHeightConstraint?.isActive = false
        }

        if self.journalEntry?.promptContentLoaded == false || self.journalEntry?.promptLoaded == false {
            self.questionLabel.showAnimatedGradientSkeleton()
        } else {
            self.questionLabel.hideSkeleton()
        }

//        self.questionLabel.showSkeleton()
    }
    
    func removeSkeletons() {
        self.responseTextView.hideSkeleton()
        self.dateLabel.hideSkeleton()
        self.questionLabel.hideSkeleton()
    }
    
    func updateView() {
        self.addSkeletons()
                
        self.contentView.isUserInteractionEnabled = true
        if let sentDate = self.sentPrompt?.firstSentAt {
            let dateString = FormatUtils.formatDate(sentDate)
            self.dateLabel.text = dateString
        } else {
            self.dateLabel.text = nil
        }
        
        let reflectContent = self.promptContent?.content.first(where: { (content) -> Bool in
            content.contentType == .reflect
        })
        
        let reflectText = FormatUtils.isBlank(reflectContent?.text) ? nil : reflectContent?.text
        let questionText = reflectText ?? self.prompt?.question
        
        if questionText != nil && self.journalEntry?.promptContentLoaded == true && self.journalEntry?.promptLoaded == true {
            self.questionLabel.text = questionText
            self.questionLabel.isHidden = false
        }
        
        let responseText = FormatUtils.responseText(self.responses)
        
        if !FormatUtils.isBlank(responseText) {
            //responses loaded and has text
            self.responseTextView.hideSkeleton()
            self.responseTextViewHeightConstraint?.isActive = false
            self.responseTextView.text = responseText
            self.showResponseView()
            
        } else if self.journalEntry?.responsesLoaded == true && FormatUtils.isBlank(responseText) {
            //responses loaded but no text
            self.removeResponseView()
            self.responseTextView.hideSkeleton()
            self.responseTextView.text = nil
        } else {
            //responses loading still
            self.responseTextView.text = nil
        }
                
        self.setNeedsLayout()
    }
    
    override func prepareForInterfaceBuilder() {
        self.layoutSubviews()
        self.configureViewAppearance()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.addShadows()
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
    
    func configureViewAppearance() {
         if self.responseTextView != nil {
            self.responseTextView.layer.borderColor = CactusColor.borderLight.cgColor
            self.responseTextView.layer.borderWidth = 0
            self.responseTextView.layer.cornerRadius = self.cornerRadius
        }
        
        self.contentView.layer.cornerRadius = self.cornerRadius
        self.layer.borderColor = UIColor.clear.cgColor
        self.layer.borderWidth = 0
        self.skeletonViewController.view.layoutSubviews()
        self.skeletonViewController.view.layoutSkeletonIfNeeded()
        self.layer.cornerRadius = 12
        self.borderView.layer.cornerRadius = 5
        self.addShadows()
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        self.responseTextViewHeightConstraint = self.responseTextView.heightAnchor.constraint(equalToConstant: 90)
        self.responseTextViewHeightConstraint?.isActive = true
        self.cellWidthConstraint = self.contentView.widthAnchor.constraint(equalToConstant: 0)
        self.configureViewAppearance()
        self.questionLabel.text = nil
        self.dateLabel.text = nil
        self.responseTextView.text = nil
    }
    
    func setCellWidth(_ width: CGFloat) {
        self.cellWidthConstraint?.constant = width
        self.cellWidthConstraint?.isActive = true
        self.setNeedsLayout()
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
