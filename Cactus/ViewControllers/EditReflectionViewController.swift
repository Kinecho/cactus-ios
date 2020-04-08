//
//  EditReflectionViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 10/31/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import UIKit

protocol EditReflectionViewControllerDelegate: class {
    func done(text: String?)
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
    var response: ReflectionResponse!
    var questionText: String?
    var isSaving: Bool = false {
        didSet {
            self.configureSaving()
        }
    }
    weak var delegate: EditReflectionViewControllerDelegate?
        
    deinit {
      NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            self.isModalInPresentation = true
        }
        
        self.questionTextView.text = questionText
        self.responseTextView.text = response.content.text
        
        self.configureView()
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.appMovedToBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }

    @objc func appMovedToForeground() {
        self.responseTextView.becomeFirstResponder()
    }
    
    @objc func appMovedToBackground() {
        self.responseTextView.resignFirstResponder()
    }
    
    func configureView() {
        self.configureSaving()
        self.responseTextView.textContainerInset = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 6)
        
        self.sharedStackView.isHidden = !(self.response.shared ?? false)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.responseTextView.becomeFirstResponder()
    }
    
    func configureSaving() {
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
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.configureSaving()
    }
    
    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        if let endFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = UIScreen.main.bounds.height - endFrame.origin.y
            editTextBottomConstraint.constant = keyboardHeight + padding
            self.view.layoutIfNeeded()
        }
    }
    
    func hasChanges() -> Bool {
        let currentText: String = self.responseTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let originalText: String = self.response.content.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        return currentText != originalText
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
        self.delegate?.done(text: self.responseTextView.text)
    }
}
