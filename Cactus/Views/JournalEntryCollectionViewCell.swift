//
//  JournalEntryCollectionViewCell.swift
//  Cactus
//
//  Created by Neil Poulin on 7/26/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import UIKit
import SkeletonView

protocol JournalEntryCollectionVieweCellDelegate: class {
    func goToDetails(cell: UICollectionViewCell)
}

@IBDesignable
class JournalEntryCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var responseTextView: UITextView!
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var dateTopContainerConstraint: NSLayoutConstraint!
    @IBOutlet weak var backgroundBlobImageView: UIImageView!
    @IBOutlet weak var subTextLabel: UILabel!
    @IBOutlet weak var backgroundImageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var statusLabelBottomToDateLabelConstraint: NSLayoutConstraint!
    @IBOutlet weak var backgroundImageTopToQuestionBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var backgroundImageTopSubTextBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var reflectButton: PrimaryButton!
    @IBOutlet weak var reflectButtonTopQuestionConstraint: NSLayoutConstraint!
    @IBOutlet weak var reflectButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var reflectButtonTopToSubTextConstraint: NSLayoutConstraint!
    @IBOutlet weak var editTextTopQuestionConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var cellWidthConstraint: NSLayoutConstraint!
    
    weak var delegate: JournalEntryCollectionVieweCellDelegate?
    
    var editViewController: EditReflectionViewController?
    var responseTextViewHeightConstraint: NSLayoutConstraint?
    var showingBackgroundImage = false
//    var cellWidthConstraint: NSLayoutConstraint?
    var responseBottomConstraint: NSLayoutConstraint?
    var textViewBottomPadding: CGFloat = 20
    var journalEntry: JournalEntry?
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
        let duration: Double = 0.5
        let activeColor = CactusColor.darkGreen
        let normalColor = CactusColor.lightGreen
        
        UIView.animate(withDuration: duration,
                       delay: 0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: -1,
                       options: .curveEaseOut,
                       animations: {
                            self.moreButton?.transform = CGAffineTransform(rotationAngle: .pi/2)
                        }, completion: { _ in
                            self.moreButton?.transform = CGAffineTransform(rotationAngle: .pi/2)
                        }
        )
        
        func closeAnimation() {
            UIView.animate(withDuration: duration * 0.75,
                           delay: 0,
                           usingSpringWithDamping: 0.5,
                           initialSpringVelocity: -1,
                           options: .curveEaseOut,
                           animations: {
                                self.moreButton?.transform = CGAffineTransform.identity
                            }, completion: { _ in
                                self.moreButton?.transform = CGAffineTransform.identity
                            })
        }
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            closeAnimation()
        }))
        
        alert.addAction(UIAlertAction(title: "Reflect", style: .default, handler: { _ in
            print("Reflect tapped")
            closeAnimation()
            self.reflectTapped()
            
        }))
                
        if !(self.responses?.isEmpty ?? true) {
            let responseText = FormatUtils.responseText(self.responses)
            let label = FormatUtils.isBlank(responseText) ? "Add Note" : "Edit Note"
            alert.addAction(UIAlertAction(title: label, style: .default) { _ in
                print("Edit reflection tapped")
                closeAnimation()
                self.startEdit()
            })
        }
        
        self.window?.rootViewController?.present(alert, animated: true)
    }
    
    func startEdit() {
        
        guard let vc = self.createEditReflectionModal() else {
            print("Unable to get the edit modal ")
            return
        }
        //            self.isEditing = true
        self.editViewController = vc
        AppDelegate.shared.rootViewController.present(vc, animated: true)

        //        responseTextView.isEditable = true
//        responseTextView.backgroundColor = .white
//        self.responseTextView.layer.borderWidth = 1
//        let bar = UIToolbar()
//        let save = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(self.saveEdit))
//        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
//        let cancel = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.cancelEdit))
//        bar.items = [cancel, spacer, save]
//        bar.sizeToFit()
//
//        responseTextView.inputAccessoryView = bar
//        responseTextView.becomeFirstResponder()
    }
    
    @objc func saveEdit(_ sender: Any?) {
        self.isEditing = false
        self.contentView.dismissKeyboard()
        
        responseTextView.isEditable = false
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
        self.contentView.dismissKeyboard()
    }
    
    func removeResponseView() {
        self.responseTextView.isHidden = true
        self.borderView.isHidden = true
        self.responseBottomConstraint?.constant = 0
        self.responseBottomConstraint?.isActive = true
        
        self.editTextTopQuestionConstraint.constant = 0
        self.editTextTopQuestionConstraint.isActive = true
    }
    
    func showResponseView() {
        self.responseTextView.isHidden = false
        self.borderView.isHidden = false
        self.responseBottomConstraint?.constant = self.textViewBottomPadding
        self.responseTextViewHeightConstraint?.isActive = false
        self.editTextTopQuestionConstraint.constant = self.textViewBottomPadding
        self.editTextTopQuestionConstraint.isActive = true
    }
    
    func configureReflectButton(show: Bool) {
        self.reflectButton.isHidden = !show
        self.reflectButtonBottomConstraint.isActive = show
        self.reflectButtonTopQuestionConstraint.isActive = show && self.subTextLabel.isHidden && !self.showingBackgroundImage
        self.reflectButtonTopToSubTextConstraint.isActive = show && !self.subTextLabel.isHidden && !self.showingBackgroundImage
    }
    
    func configureBackgroundImage(show: Bool) {
        if show, let contentImage = self.promptContent?.content.first?.backgroundImage, !contentImage.isEmpty() {
            self.showingBackgroundImage = true
            ImageService.shared.setPhoto(self.backgroundImageView, photo: contentImage)
            self.backgroundImageView.isHidden = false
            self.backgroundBlobImageView.isHidden = false
            self.backgroundImageTopToQuestionBottomConstraint.isActive = self.subTextLabel.isHidden
            self.backgroundImageTopSubTextBottomConstraint.isActive = !self.subTextLabel.isHidden
                        
            self.reflectButtonTopQuestionConstraint.isActive = false
            self.reflectButtonTopToSubTextConstraint.isActive = false
            self.backgroundImageHeightConstraint.isActive = true
        } else {
            self.backgroundImageHeightConstraint.isActive = false
            self.showingBackgroundImage = false
            self.backgroundImageView.image = nil
            self.backgroundImageTopToQuestionBottomConstraint.isActive = false
            self.backgroundImageTopSubTextBottomConstraint.isActive = false
            
            self.backgroundImageView.isHidden = true
            self.backgroundBlobImageView.isHidden = true
        }
    }
    
    func getQuestionText() -> String? {
        let reflectContent = self.promptContent?.content.first(where: { (content) -> Bool in
            content.contentType == .reflect
        })
                        
        let reflectText = FormatUtils.isBlank(reflectContent?.text) ? nil : reflectContent?.text
        let questionText = reflectText ?? self.prompt?.question
        return questionText
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
        
//        let reflectContent = self.promptContent?.content.first(where: { (content) -> Bool in
//            content.contentType == .reflect
//        })
//
//        let reflectText = FormatUtils.isBlank(reflectContent?.text) ? nil : reflectContent?.text
//        let questionText = reflectText ?? self.prompt?.question
        let questionText = self.getQuestionText()
        let subjectLine = self.promptContent?.subjectLine
        let firstText = self.promptContent?.content.first?.text
        let promptAndContentLoaded = self.journalEntry?.promptContentLoaded == true && self.journalEntry?.promptLoaded == true
        let responsesLoaded = self.journalEntry?.responsesLoaded == true
        let reflectionCompleted = responsesLoaded && !(responses?.isEmpty ?? true)
        let allLoaded = promptAndContentLoaded && responsesLoaded
        
        //adding for good measure....
        self.backgroundImageHeightConstraint.isActive = false
        
        self.subTextLabel.text = firstText
        let responseText = FormatUtils.responseText(self.responses)
        
        if allLoaded {
            if self.questionLabel.isSkeletonActive {
                self.questionLabel.hideSkeleton()
            }
            
            if reflectionCompleted {
                self.questionLabel.text = questionText
                self.questionLabel.numberOfLines = 0
                self.questionLabelHeightConstraint?.isActive = false
                self.subTextLabel.isHidden = true
            } else {
                if subjectLine != nil {
                    self.questionLabel.text = subjectLine
                    self.questionLabel.numberOfLines = 0
                    self.questionLabelHeightConstraint?.isActive = false
                }
                
                if firstText != nil {
                    self.subTextLabel.isHidden = false
                } else {
                    self.subTextLabel.isHidden = true
                }
            }
            
            if FormatUtils.isBlank(responseText) {
                //responses loaded but no text
                self.responseTextViewHeightConstraint?.isActive = false
                self.responseTextView.text = nil
                self.responseTextView.hideSkeleton()
                self.removeResponseView()
            }
    
            self.configureBackgroundImage(show: !reflectionCompleted)
            self.configureReflectButton(show: !reflectionCompleted && promptContent != nil)
        } else {
            self.questionLabel.text = nil
            self.questionLabel.numberOfLines = 1
            self.configureBackgroundImage(show: false)
            self.configureReflectButton(show: false)
            self.questionLabel.showAnimatedGradientSkeleton()
            self.questionLabelHeightConstraint?.isActive = true
            
            //responses loading still
            self.showResponseView()
            self.responseTextView.text = nil
            self.responseBottomConstraint?.constant = self.textViewBottomPadding
//            self.responseTextViewHeightConstraint.priority = UILayoutPriority(999)
            self.responseTextViewHeightConstraint?.isActive = true
            self.responseTextView.showAnimatedGradientSkeleton()
            
        }
        
        if !FormatUtils.isBlank(responseText) {
            //responses loaded and has text
            self.showResponseView()
            self.responseTextView.hideSkeleton()
            self.responseTextView.text = responseText
        }
//        } else if self.journalEntry?.responsesLoaded == true && FormatUtils.isBlank(responseText) {
//        } else if allLoaded && FormatUtils.isBlank(responseText) {
//            //responses loaded but no text
//            self.responseTextViewHeightConstraint?.isActive = false
//            self.responseTextView.text = nil
//            self.responseTextView.hideSkeleton()
//            self.removeResponseView()
//
//        } else {
//            //responses loading still
//            self.responseTextView.text = nil
//            self.responseBottomConstraint?.constant = self.textViewBottomPadding
//            self.responseTextViewHeightConstraint?.priority = UILayoutPriority(999)
//            self.responseTextViewHeightConstraint?.isActive = true
////            self.responseTextView.rounded
//            self.responseTextView.showAnimatedGradientSkeleton()
//        }
               
        if self.responses?.isEmpty == false && self.journalEntry?.responsesLoaded == true {
            self.statusLabel.isHidden = false
            self.dateTopContainerConstraint.isActive = false
            self.statusLabelBottomToDateLabelConstraint.isActive = true
        } else {
            self.statusLabel.isHidden = true
            self.statusLabelBottomToDateLabelConstraint.isActive = false
            self.dateTopContainerConstraint.isActive = true
        }
        
        self.setNeedsLayout()
    }
    
    override func prepareForInterfaceBuilder() {
        self.layoutSubviews()
        self.sharedInit()
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
    
    func sharedInit() {
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        self.responseTextViewHeightConstraint = self.responseTextView.heightAnchor.constraint(equalToConstant: 90)
        self.questionLabelHeightConstraint = self.questionLabel.heightAnchor.constraint(equalToConstant: 30)
        self.questionLabelHeightConstraint?.identifier = "QuestionLabel.height"
        self.questionLabelHeightConstraint?.isActive = false

//        self.responseTextViewHeightConstraint?.priority
        self.responseTextViewHeightConstraint?.isActive = false
        
        self.configureViewAppearance()
        self.questionLabel.text = nil
        self.dateLabel.text = nil
        self.responseTextView.text = nil
        
        self.responseBottomConstraint = self.contentView.constraintWithIdentifier("responseBottom")
        self.textViewBottomPadding = self.responseBottomConstraint?.constant ?? 20
        
        let textTappedGesture = UITapGestureRecognizer(target: self, action: #selector(self.reflectTapped))
        self.responseTextView.addGestureRecognizer(textTappedGesture)
        self.configureReflectButton(show: false)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.sharedInit()
    }
    
    @IBAction func reflectButtonTapped(_ sender: Any) {
        self.delegate?.goToDetails(cell: self)
    }
    
    @objc func reflectTapped() {
        self.delegate?.goToDetails(cell: self)
    }
    
    func setCellWidth(_ width: CGFloat) {
        self.cellWidthConstraint?.constant = width
        self.cellWidthConstraint?.isActive = true
        self.setNeedsLayout()
    }
    
    //TODO: Removed while testing layout updates to the collection view
    //from article: The default implementation of this method simply applies any autolayout constraints to the configured view. If the size is different, it will return a preferred set of attributes.
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        setNeedsLayout()
        layoutIfNeeded()
        let size = contentView.systemLayoutSizeFitting(layoutAttributes.size)
        frame.size.height = ceil(size.height) + 1
        layoutAttributes.frame = frame

        return layoutAttributes
    }
}

extension JournalEntryCollectionViewCell: EditReflectionViewControllerDelegate {
    func createEditReflectionModal() -> EditReflectionViewController? {
        let editView = EditReflectionViewController.loadFromNib()
        editView.delegate = self
        
        var response = self.responses?.first
        if response == nil, let promptId = self.sentPrompt?.promptId {
            response = ReflectionResponseService.sharedInstance.createReflectionResponse(promptId, promptQuestion: self.prompt?.question)
        }
        
        guard let reflectionResponse = response else {
            return nil
        }
        
        editView.response = reflectionResponse
        editView.questionText = self.getQuestionText()
        
        return editView
    }
    
    func done(text: String?) {
        print("Saving text: \(text ?? "None provided")")
        guard let response = self.editViewController?.response else {return}
        
        response.content.text = text
        self.updateView()
        
        ReflectionResponseService.sharedInstance.save(response) { (saved, error) in
            print("Saved the response! \(saved?.id ?? "no id found")")
            self.editViewController?.isSaving = false
             if error == nil {
                 self.editViewController?.dismiss(animated: true, completion: nil)
             }
        }

    }
    
    func cancel() {
        self.editViewController?.dismiss(animated: true, completion: nil)
    }
}
