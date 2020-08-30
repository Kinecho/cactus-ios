//
//  ReflectContentViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 9/17/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import UIKit
import AVKit

class ReflectContentViewController: PromptContentViewController {
    @IBOutlet weak var questionTextView: UITextView!
    @IBOutlet weak var addNoteButton: BorderedButton!
    @IBOutlet weak var reflectionTextView: UITextView!
    @IBOutlet weak var sharedNoteStackView: UIStackView!
    @IBOutlet weak var elementAnimationWebView: CactusElementWebView!
    var reflectLogger = Logger(fileName: "ReflectionContentViewController")
    var player: AVPlayer!
//    var reflectionResponse: ReflectionResponse? {
//        didSet {
//            self.configureResponseView()
//        }
//    }
    var editViewController: EditReflectionViewController?
        
    var startTime: Date?
    var endTime: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let promptId = self.promptContent.promptId, self.reflectionResponse == nil {
            let question = self.promptContent.getQuestion()
            let element = self.promptContent.cactusElement
            self.reflectionResponse = ReflectionResponseService.sharedInstance.createReflectionResponse(promptId, promptQuestion: question, element: element, medium: .PROMPT_IOS)
        }
        self.initializeView()
        self.configureView()
        self.createAnimation()
    }
   
    func getQuestionMarkdownString() -> String? {
        return self.content.getDisplayText(member: self.member, preferredIndex: self.promptContent.preferredCoreValueIndex, response: self.reflectionResponse)
    }
    
    func createAnimation() {
        let element = self.promptContent.cactusElement
        self.elementAnimationWebView.element = element
        self.elementAnimationWebView.isHidden = false
        self.elementAnimationWebView.updateView()
        
    }
    
    func configureNote() {
        guard self.isViewLoaded else {
            return
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.startTime = Date()
        self.endTime = nil
        self.elementAnimationWebView.startAnimation()
    }
        
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.elementAnimationWebView.pauseAnimation()
    }
    
    @IBAction func addNoteTapped(_ sender: Any) {
        Vibration.selection.vibrate()
        let editVc = self.createEditReflectionModal()
        self.editViewController = editVc
        self.present(editVc, animated: true)
    }
        
    @objc func doneAction(_ sender: Any) {
        self.reflectLogger.info("Done button tapped")
        self.saveResponse(nextPageOnSuccess: true, silent: false) { (saved, _) in
            if let saved = saved {
                self.reflectionResponse = saved
            }
        }
        view.endEditing(true)
    }
    
    func setSaving(_ isSaving: Bool) {
        self.editViewController?.isSaving = isSaving
        if isSaving {
            self.addNoteButton.setTitle("Saving...", for: .disabled)
            self.addNoteButton.isEnabled = false
        } else {
            self.addNoteButton.isEnabled = true
        }
    }
    
    func saveResponse(nextPageOnSuccess: Bool=true, silent: Bool = false, _ completion: ((ReflectionResponse?, Any?) -> Void)?=nil) {
        //Note: The text must be set on the ReflectionResponse object, we will not grab it from the text input here.
        self.reflectLogger.debug("saving response...")
        guard let response = self.reflectionResponse else {
            self.reflectLogger.warn("No reflection Response found on the ReflectContentCardViewControler. Unable to save the response")
            completion?(nil, "No reflection response was found")
            return
        }
        self.endTime = Date()
        var durationMs: Double?
        if let startTime = self.startTime, let endTime = self.endTime {
            durationMs = endTime.timeIntervalSince(startTime) * 1000
        }
        if let duration = durationMs {
            response.reflectionDurationMs = (response.reflectionDurationMs ?? 0) + Int(duration)
        }
        response.cactusElement = self.promptContent.cactusElement
        if !silent {
            self.setSaving(true)
        }
        
        super.delegate?.save(response, nextPageOnSuccess: nextPageOnSuccess, addReflectionLog: true, completion: { (saved, error) in
            if let error = error {
                self.reflectLogger.error("Error saving reflection response", error)
            }
            
            if !silent {
                self.setSaving(false)
            }
            completion?(saved, error)
        })
        
    }
    
    func createEditReflectionModal() -> EditReflectionViewController {
        let editView = EditReflectionViewController.loadFromNib()
        editView.delegate = self
        editView.response = self.reflectionResponse
        editView.questionText = self.getQuestionMarkdownString()        
        return editView
    }
    
    override func memberDidSet(updated: CactusMember?, previous: CactusMember? ) {
        super.memberDidSet(updated: updated, previous: previous)
        self.configureView()
    }
    
    override func reflectionResponseDidSet(updated: ReflectionResponse?, previous: ReflectionResponse?) {
        super.reflectionResponseDidSet(updated: updated, previous: previous)
        self.configureView()
    }
 
    func initializeView() {
        self.view.backgroundColor = CactusColor.promptBackground
        self.reflectionTextView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.addNoteTapped)))
        self.reflectionTextView.layer.borderWidth = 1
        self.reflectionTextView.layer.cornerRadius = 12
        self.reflectionTextView.layer.borderColor = CactusColor.textMinimized.cgColor
    }
    
    override func configureView() {
        guard self.isViewLoaded else {
            return
        }
        let questionText = self.getQuestionMarkdownString()
        self.questionTextView.attributedText = MarkdownUtil.centeredMarkdown(questionText?.preventOrphanedWords(), font: CactusFont.normal(24))
        
        self.configureResponseView()
    }

    func configureResponseView() {
        guard self.isViewLoaded else {return}
        if FormatUtils.isBlank(self.reflectionResponse?.content.text) {
            self.reflectionTextView.isHidden = true
            self.addNoteButton.isHidden = false
            self.sharedNoteStackView.isHidden = true
        } else {
            self.reflectionTextView.isHidden = false
            self.reflectionTextView.text = self.reflectionResponse?.content.text
            self.addNoteButton.isHidden = true            
            self.sharedNoteStackView.isHidden = !(self.reflectionResponse?.shared ?? false)
        }
    }
    
    @objc private func tapGestureHandler() {
        view.endEditing(true)
    }
    
    override func viewWillLayoutSubviews() {
        self.view.backgroundColor = CactusColor.promptBackground
    }
}

extension ReflectContentViewController: GrowingTextViewDelegate {
    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
        self.reflectLogger.debug("text view did change height")
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: [.curveLinear], animations: { () -> Void in
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
}

extension ReflectContentViewController: EditReflectionViewControllerDelegate {    
    func done(text: String?, response: ReflectionResponse?, title: String?, prompt: ReflectionPrompt?) {
        self.reflectLogger.info("Saving text: \(text ?? "None provided")")
        self.reflectionResponse?.content.text = text
        self.configureResponseView()
        self.saveResponse(nextPageOnSuccess: false) { (_, error) in
            self.editViewController?.isSaving = false
            if error == nil {
                self.editViewController?.dismiss(animated: true, completion: {
                    self.delegate?.nextScreen()
                })
            } else {
                self.reflectLogger.error("Failed to save the reflection response", error)
            }
        }
    }
    
    func cancel() {
        self.editViewController?.dismiss(animated: true, completion: nil)
    }
}
