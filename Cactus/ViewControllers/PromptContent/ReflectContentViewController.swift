//
//  ReflectContentViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 9/17/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import UIKit

class ReflectContentViewController: UIViewController {

    var content: Content!
    var promptContent: PromptContent!
    var reflectionResponse: ReflectionResponse?
    
//    @IBOutlet weak var inputToolbar: UIView!
    @IBOutlet weak var questionTextView: UITextView!
    var inputToolbar: UIView!
    var textView: GrowingTextView!
    private var textViewBottomConstraint: NSLayoutConstraint!

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO: Get the reflection response, either here or in the parent
        
        self.createInputView()
        self.configureView()
        
        if let response = self.reflectionResponse {
            self.textView.text = response.content.text
        } else {
            self.textView.text = nil
        }    
    }

    func createInputView() {
        
        // *** Create Toolbar
        self.inputToolbar = UIView()
        inputToolbar.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        inputToolbar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(inputToolbar)
        
        // *** Create GrowingTextView ***
        textView = GrowingTextView()
        textView.delegate = self
        textView.layer.cornerRadius = 12.0
//        textView.maxLength = 200
        textView.maxHeight = 200
        textView.trimWhiteSpaceWhenEndEditing = true
        textView.placeholder = "Say something..."
        textView.placeholderColor = UIColor(white: 0.8, alpha: 1.0)
        textView.font = CactusFont.normal
        textView.translatesAutoresizingMaskIntoConstraints = false
        inputToolbar.addSubview(textView)
        
        // *** Autolayout ***
        let topConstraint = textView.topAnchor.constraint(equalTo: inputToolbar.topAnchor, constant: 8)
        topConstraint.priority = UILayoutPriority(999)
        NSLayoutConstraint.activate([
            inputToolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            inputToolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            inputToolbar.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            topConstraint
            ])
        
        if #available(iOS 11, *) {
            textViewBottomConstraint = textView.bottomAnchor.constraint(equalTo: inputToolbar.safeAreaLayoutGuide.bottomAnchor, constant: -8)
            NSLayoutConstraint.activate([
                textView.leadingAnchor.constraint(equalTo: inputToolbar.safeAreaLayoutGuide.leadingAnchor, constant: 8),
                textView.trailingAnchor.constraint(equalTo: inputToolbar.safeAreaLayoutGuide.trailingAnchor, constant: -8),
                textViewBottomConstraint
                ])
        } else {
            textViewBottomConstraint = textView.bottomAnchor.constraint(equalTo: inputToolbar.bottomAnchor, constant: -8)
            NSLayoutConstraint.activate([
                textView.leadingAnchor.constraint(equalTo: inputToolbar.leadingAnchor, constant: 8),
                textView.trailingAnchor.constraint(equalTo: inputToolbar.trailingAnchor, constant: -8),
                textViewBottomConstraint
                ])
        }
        
        // *** Listen to keyboard show / hide ***
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        // *** Hide keyboard when tapping outside ***
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapGestureHandler))
        view.addGestureRecognizer(tapGesture)
    }
    
    func configureView() {
        let questionText = !FormatUtils.isBlank(content.text_md) ? content.text_md : content.text
        self.questionTextView.attributedText = MarkdownUtil.centeredMarkdown(questionText, font: CactusFont.large)
    }

    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        if let endFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            var keyboardHeight = UIScreen.main.bounds.height - endFrame.origin.y
            if #available(iOS 11, *) {
                if keyboardHeight > 0 {
                    keyboardHeight -= view.safeAreaInsets.bottom
                }
            }
            textViewBottomConstraint.constant = -keyboardHeight - 8
            view.layoutIfNeeded()
        }
    }
    
    @objc private func tapGestureHandler() {
        view.endEditing(true)
    }
    
}

extension ReflectContentViewController: GrowingTextViewDelegate {
    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
        print("text view did change height")
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: [.curveLinear], animations: { () -> Void in
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
}
