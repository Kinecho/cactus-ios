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
    var responseBottomConstraint: NSLayoutConstraint?
    var textViewBottomPadding: CGFloat = 20
    @IBOutlet weak var borderView: UIView!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var dateTopContainerConstraint: NSLayoutConstraint!
    var journalEntry: JournalEntry?
    var responseTextViewHeightConstraint: NSLayoutConstraint?
    var questionLabelHeightConstraint: NSLayoutConstraint?
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
        self.responseTextView.isHidden = true
        self.borderView.isHidden = true
        self.responseBottomConstraint?.constant = 0
        self.responseBottomConstraint?.isActive = true
    }
    
    func showResponseView() {
        self.responseTextView.isHidden = false
        self.borderView.isHidden = false
        self.responseBottomConstraint?.constant = self.textViewBottomPadding
        self.responseTextViewHeightConstraint?.isActive = false
    }
    
    func updateView() {
        if let sentDate = self.sentPrompt?.firstSentAt {
            let dateString = FormatUtils.formatDate(sentDate)
            self.dateLabel.text = dateString
            self.dateLabel.hideSkeleton()
        } else {
            self.dateLabel.text = nil
            self.dateLabel.showAnimatedGradientSkeleton()
        }
        
        let reflectContent = self.promptContent?.content.first(where: { (content) -> Bool in
            content.contentType == .reflect
        })
        
        let reflectText = FormatUtils.isBlank(reflectContent?.text) ? nil : reflectContent?.text
        let questionText = reflectText ?? self.prompt?.question
        let questionLoaded = self.journalEntry?.promptContentLoaded == true && self.journalEntry?.promptLoaded == true
        
        if questionLoaded {
            if self.questionLabel.isSkeletonActive {
                self.questionLabel.hideSkeleton()
            }
            self.questionLabel.text = questionText
            self.questionLabel.numberOfLines = 0
            self.questionLabelHeightConstraint?.isActive = false
        } else {
            self.questionLabel.text = nil
            self.questionLabel.numberOfLines = 1
            
//            if !self.questionLabel.isSkeletonActive {
                self.questionLabel.showAnimatedGradientSkeleton()
//            }
            self.questionLabelHeightConstraint?.isActive = true
            
        }
        
        let responseText = FormatUtils.responseText(self.responses)
        
        if !FormatUtils.isBlank(responseText) {
            //responses loaded and has text
            self.showResponseView()
            self.responseTextView.hideSkeleton()
            self.responseTextView.text = responseText
        } else if self.journalEntry?.responsesLoaded == true && FormatUtils.isBlank(responseText) {
            //responses loaded but no text
            self.responseTextViewHeightConstraint?.isActive = false
            self.responseTextView.text = nil
            self.responseTextView.hideSkeleton()
            self.removeResponseView()
            
        } else {
            //responses loading still
            self.responseTextView.text = nil
            self.responseBottomConstraint?.constant = self.textViewBottomPadding
            self.responseTextViewHeightConstraint?.isActive = true
            self.responseTextView.showAnimatedGradientSkeleton()
        }
               
        if self.responses?.isEmpty == false && self.journalEntry?.responsesLoaded == true {
            self.statusLabel.isHidden = false
            self.dateTopContainerConstraint.isActive = false
        } else {
            self.statusLabel.isHidden = true
            self.dateTopContainerConstraint.isActive = true
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
        self.questionLabelHeightConstraint = self.questionLabel.heightAnchor.constraint(equalToConstant: 30)
        
        self.questionLabelHeightConstraint?.isActive = true
        self.responseTextViewHeightConstraint?.isActive = false
        
        self.cellWidthConstraint = self.contentView.widthAnchor.constraint(equalToConstant: 0)
        self.configureViewAppearance()
        self.questionLabel.text = nil
        self.dateLabel.text = nil
        self.responseTextView.text = nil
        
        self.responseBottomConstraint = self.contentView.constraintWithIdentifier("responseBottom")
        self.textViewBottomPadding = self.responseBottomConstraint?.constant ?? 20
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
