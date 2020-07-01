//
//  JournalEntryCell.swift
//  Cactus
//
//  Created by Neil Poulin on 5/4/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import UIKit
import SkeletonView

protocol JournalEntryCollectionVieweCellDelegate: EditReflectionViewControllerDelegate {
    func goToDetails(cell: UICollectionViewCell)
    func presentEditReflectionModal(_ data: JournalEntry) -> EditReflectionViewController?
}

class JournalEntryCell: UICollectionViewCell {
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var subTextLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var moreButton: BorderedButton!
    
    @IBOutlet weak var responseStackView: UIStackView!
    @IBOutlet weak var responseHighlightView: UIView!
    @IBOutlet weak var responseTextView: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var responseStackViewHeightConstraint: NSLayoutConstraint!
    var editViewController: EditReflectionViewController?
    var skeletonGradient = SkeletonGradient(baseColor: CactusColor.skeletonBase)
    weak var delegate: JournalEntryCollectionVieweCellDelegate?
    let logger = Logger("JournalEntryCell")
    var margin: CGFloat = 20
    
    @IBOutlet weak var responseTextViewHeightConstraint: NSLayoutConstraint!
    var data: JournalEntry? {
        didSet {
            self.updateView()
        }
    }
    
    // MARK: Computed properties
    var sentPrompt: SentPrompt? {
        return self.data?.sentPrompt
    }
    var responses: [ReflectionResponse]? {
        return self.data?.responses
    }
    
    var responseText: String? {
        return self.responses?.first?.content.text
    }
    
    var reflectionDate: Date? {
        return self.data?.sentPrompt?.firstSentAt ?? self.responses?.first?.reflectionDates?.first ?? self.responses?.first?.updatedAt
    }
    
    var prompt: ReflectionPrompt? {
        return self.data?.prompt
    }
    var promptContent: PromptContent? {
        return self.data?.promptContent
    }
    
    var allLoaded: Bool {
        return self.data?.loadingComplete ?? false
    }
    
    var hasReflected: Bool {
        return self.responses?.isEmpty == false
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.layer.cornerRadius = 10
        self.contentView.layer.cornerRadius = 10
        self.contentView.clipsToBounds = true
        self.responseHighlightView.layer.cornerRadius = self.responseHighlightView.bounds.width
        self.responseHighlightView.clipsToBounds = true
        self.responseTextView.textContainerInset = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 20)
        self.responseTextView.contentInset = UIEdgeInsets.zero
        self.responseTextView.isScrollEnabled = false
        self.responseTextView.textContainer.lineFragmentPadding = 0
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 10.0)
        self.layer.shadowRadius = self.layer.cornerRadius
        self.layer.shadowOpacity = 0.2
        self.layer.masksToBounds = false
        self.responseHighlightView.transform = CGAffineTransform.identity.translatedBy(x: -1 * self.responseHighlightView.bounds.width / 2, y: 0)
        self.layer.shadowPath = UIBezierPath(roundedRect: self.contentView.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath
        
//        self.layoutSkeletonIfNeeded()
    }
    
    func updateView() {
        guard self.allLoaded else {
            self.showLoading()
            return
        }
        
//        self.showLoading()
        
        self.showLoadingComplete()
        self.layoutSkeletonIfNeeded()
        self.setNeedsLayout()
    }
    
    func showLoading() {
        self.questionLabel.text = ""
        self.subTextLabel.text = nil
        self.subTextLabel.isHidden = true
        
        self.responseStackView.isHidden = false
        self.responseTextView.text = nil
        
//        self.imageHeightConstraint.isActive = true
        self.imageView.isHidden = false
        self.dateLabel.text = ""
        self.moreButton.isHidden = true
        self.questionLabel.numberOfLines = 2
        self.questionLabel.isHidden = false
        
        self.responseTextViewHeightConstraint.isActive = false
        self.responseStackViewHeightConstraint.isActive = true
        self.updateGradient(self.imageView, show: true)
        self.updateGradient(self.questionLabel, show: true)
        self.updateGradient(self.responseTextView, show: true)
    }
    
    func showLoadingComplete() {
        guard let data = self.data else {
            self.showLoading()
            return
        }
        self.responseTextViewHeightConstraint.isActive = false
        self.responseStackViewHeightConstraint.isActive = false
        self.updateGradient(self.imageView, show: false)
        self.updateGradient(self.questionLabel, show: false)
        self.updateGradient(self.responseTextView, show: false)

        self.moreButton.isHidden = false
        if data.isTodaysPrompt {
            self.dateLabel.text = "Today"
        } else if let reflectionDate = self.reflectionDate {
            self.dateLabel.text = FormatUtils.formatDate(reflectionDate)
        } else {
            self.dateLabel.text = ""
        }
        
        if let responseText = self.responseText, !isBlank(responseText) {
            self.responseStackView.isHidden = false
            self.responseTextView.text = responseText
            
        } else {
            self.responseStackView.isHidden = true
        }
        
        if self.promptContent?.getMainImageFile() != nil {
            self.imageView.setImageFile(self.promptContent?.getMainImageFile())
        } else {
            self.imageView.isHidden = true
        }
        
        let firstTextMd = self.promptContent?.getIntroTextMarkdown()
        if !hasReflected && !isBlank(firstTextMd) {
            self.subTextLabel.attributedText = MarkdownUtil.toMarkdown(firstTextMd)
            self.subTextLabel.isHidden = false
        } else {
            self.subTextLabel.isHidden = true
        }
        
        self.questionLabel.numberOfLines = 0
        self.questionLabel.attributedText = MarkdownUtil.toMarkdown(self.getQuestionText(), font: CactusFont.bold(22))
    }
    
    func setWidth(_ width: CGFloat) {
        if self.widthConstraint.constant == width {
            return
        }
        self.widthConstraint.constant = width
        self.widthConstraint.isActive = true
        self.setNeedsLayout()
        self.layoutSkeletonIfNeeded()
    }
    
    func updateGradient(_ view: UIView, show: Bool) {
        if show && !view.isSkeletonActive {
            view.showAnimatedGradientSkeleton(usingGradient: self.skeletonGradient)
        } else if !show {
            if view.isSkeletonActive {
                view.hideSkeleton(reloadDataAfter: true, transition: .crossDissolve(0.5))
            }
        }
        
        if show {
            view.layoutSkeletonIfNeeded()
        }
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
    
    @IBAction func moreButtonTapped(_ sender: UIButton) {
        let duration: Double = 0.5
        let responseText = FormatUtils.responseText(self.responses)
        let isComplete = !(self.responses?.isEmpty ?? true)
        let hasNote = !FormatUtils.isBlank(responseText)
        
        UIView.animate(withDuration: duration,
                       delay: 0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: -1,
                       options: .curveEaseOut,
                       animations: {
                        self.moreButton?.transform = CGAffineTransform(rotationAngle: .pi/2)
        }, completion: { _ in
            self.moreButton?.transform = CGAffineTransform(rotationAngle: .pi/2)
        })
        
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
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = sender
        }
        
        if self.promptContent != nil {
            alert.addAction(UIAlertAction(title: "Reflect", style: .default, handler: { _ in
                self.logger.info("Reflect tapped")
                closeAnimation()
                self.reflectTapped()
            }))
        }
        
        if isComplete || self.prompt?.isCustomPrompt == true {
            let label = hasNote ? "Edit Note" : "Add Note"
            alert.addAction(UIAlertAction(title: label, style: .default) { _ in
                self.logger.debug("Edit reflection tapped")
                closeAnimation()
                self.startEdit()
            })
        }
        
        // only show the reflect button if there is prompt content
        if let promptContent = self.promptContent {
            alert.addAction(UIAlertAction(title: "Share Prompt", style: .default) { _ in
                closeAnimation()
                self.logger.info("Share Prompt tapped")
                SharingService.shared.sharePromptContent(promptContent: promptContent, target: AppMainViewController.shared, sender: sender)
            })
        }
        
        if hasNote {
            alert.addAction(UIAlertAction(title: "Share Note", style: .default, handler: { _ in
                closeAnimation()
                guard let reflectionResponse = self.responses?.first else {
                    return
                }
                
                let vc = ShareNoteViewController.loadFromNib()
                vc.reflectionResponse = reflectionResponse
                vc.promptContent = self.promptContent
                vc.prompt = self.prompt
                AppMainViewController.shared.present(vc, animated: true)
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            closeAnimation()
        }))
        
        NavigationService.sharedInstance.present(alert, animated: true)
    }
    
    // MARK: Actions functions
    func startEdit() {
        guard let data = self.data, self.delegate?.presentEditReflectionModal(data) != nil else {
            self.logger.warn("Unable to get the edit modal", functionName: #function)
            return
        }        
    }
    
    @objc func reflectTapped() {
        self.delegate?.goToDetails(cell: self)
    }
    
    // MARK: Helper functions
    func getQuestionText() -> String? {
//        let reflectContent = self.promptContent?.content.first(where: { (content) -> Bool in
//            content.contentType == .reflect
//        })
//        let reflectText = FormatUtils.isBlank(reflectContent?.text) ? nil : reflectContent?.text
        let member = CactusMemberService.sharedInstance.currentMember
        let coreValue = self.responses?.first { $0.coreValue != nil }?.coreValue
        var dynamicValues: DynamicResponseValues = [:]
        self.responses?.forEach({ (response) in
            dynamicValues.merge(response.dynamicValues ?? [:]) { (_, new) -> String? in
                new
            }
        })
        let questionText = self.promptContent?.getDisplayableQuestion(member: member, coreValue: coreValue, dynamicValues: dynamicValues) ?? self.prompt?.question
        return questionText?.preventOrphanedWords()
    }
}
