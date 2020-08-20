//
//  EditReflectionViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 10/31/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import UIKit

protocol EditReflectionViewControllerDelegate: class {
//    func done(text: String?, response: ReflectionResponse?)
    func done(text: String?, response: ReflectionResponse?, title: String?, prompt: ReflectionPrompt?)
    func cancel()
}

class EditReflectionViewController: UIViewController, UIAdaptivePresentationControllerDelegate {
    @IBOutlet weak var questionTextView: UITextView!
    @IBOutlet weak var responseTextView: UITextView!
    @IBOutlet var editTextBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var doneButton: BorderedButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var buttonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var sharedStackView: UIStackView!
    let logger = Logger("EditReflectionViewController")
    let padding: CGFloat = 10
    var response: ReflectionResponse?
    var prompt: ReflectionPrompt?
    let placeholderColor = CactusColor.placeholderText
    var questionText: String?
    var isSaving: Bool = false {
        didSet {
            DispatchQueue.main.async {
                self.configureSaving()
            }            
        }
    }
    weak var delegate: EditReflectionViewControllerDelegate?
        
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
        self.responseTextView.delegate = nil
        self.responseTextView.resignFirstResponder()
        self.responseTextView.removeFromSuperview()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            self.isModalInPresentation = true
        }
        self.questionTextView.accessibilityLabel = "Title"
        self.responseTextView.accessibilityLabel = "Write something..."
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.appMovedToBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        self.configureView()
        
    }

    @objc func appMovedToBackground() {
        guard self.isViewLoaded else {
            return
        }
        self.responseTextView.resignFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if isBlank(self.response?.content.text) {
            self.responseTextView.becomeFirstResponder()
        }
    }
    
    func configureView() {
        guard self.isViewLoaded else {
            return
        }
        self.questionTextView.isEditable = self.prompt?.isCustomPrompt == true
        if self.prompt?.isCustomPrompt == true {
            self.questionTextView.text = self.questionText ?? ""
            if self.questionText?.isEmpty == false {
                self.questionTextView.textColor = CactusColor.textDefault
            } else {
                self.questionTextView.text = self.questionTextView.accessibilityLabel
                self.questionTextView.textColor = CactusColor.placeholderText
            }
            self.questionTextView.delegate = self

        } else if let questionMarkdown = MarkdownUtil.toMarkdown(questionText ?? "", font: CactusFont.normal(24)) {
            self.questionTextView.attributedText = questionMarkdown
        } else {
            self.questionTextView.text = ""
        }

        self.responseTextView.text = self.response?.content.text ?? self.responseTextView.accessibilityLabel
        self.responseTextView.delegate = self
        self.responseTextView.textColor = isBlank(self.response?.content.text ?? "") ? CactusColor.placeholderText : CactusColor.textDefault

        self.configureSaving()
        self.responseTextView.textContainerInset = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 6)

        self.sharedStackView.isHidden = !(self.response?.shared ?? false)
        
    }
   
    func configureSaving() {
        guard self.isViewLoaded else {
            return
        }
        if self.isSaving {
            self.doneButton.setImage(UIImage(), for: .disabled)
            self.doneButton.setTitle("Saving...", for: .disabled)
            self.doneButton.isEnabled = false
            self.doneButton.backgroundColor = CactusColor.gray
            self.buttonWidthConstraint.constant = 125
        } else {
            self.doneButton.isEnabled = true
            self.buttonWidthConstraint.constant = 50
            self.doneButton.backgroundColor = CactusColor.green
        }
    }
    
//    override func viewWillLayoutSubviews() {
//        super.viewWillLayoutSubviews()
//        self.configureSaving()
//    }
    
    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        if let endFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = UIScreen.main.bounds.height - endFrame.origin.y
            editTextBottomConstraint.constant = keyboardHeight + padding
            self.view.layoutIfNeeded()
        }
    }
    
    func hasChanges() -> Bool {
        guard self.isViewLoaded else {
            return false
        }
        let currentText: String = self.responseTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let originalText: String = self.response?.content.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        let questionChanged = self.questionTextView.text != (self.questionText ?? "")
        
        return currentText != originalText || questionChanged
    }
    
    func handleDismiss(_ sender: UIView?) {
        if self.hasChanges() {
            let alert = UIAlertController(title: "You have unsaved changes",
                                          message: "Are you sure you want to close this window? Your changes will be lost.",
                                          preferredStyle: .actionSheet)
            
            alert.popoverPresentationController?.sourceView = sender
            
            alert.addAction(UIAlertAction(title: "Don't Save", style: .destructive, handler: { (_) in
                self.delegate?.cancel()
            }))
            alert.addAction(UIAlertAction(title: "Save Changes", style: .default, handler: { (action) in
                self.doneButtonTapped(action)
            }))
            self.present(alert, animated: true, completion: nil)
            
        } else {
            self.delegate?.cancel()
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        self.logger.info("cancel tapped")
        self.handleDismiss(sender)
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        self.logger.info("done tapped")
//        self.delegate?.done(text: self.responseTextView.text)
        if self.prompt == nil || self.prompt?.isCustomPrompt != true {
            self.delegate?.done(text: self.responseTextView.text, response: self.response, title: nil, prompt: nil )
        } else {
            self.delegate?.done(text: self.responseTextView.text, response: self.response, title: self.questionTextView.text, prompt: self.prompt )
        }
        
    }
}

extension EditReflectionViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == self.placeholderColor {
            textView.text = nil
            textView.textColor = CactusColor.textDefault
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        let t = textView.text ?? ""
        
        if t.isEmpty {
            textView.text = textView.accessibilityLabel ?? ""
            textView.textColor = self.placeholderColor
        }
    }
    
}
