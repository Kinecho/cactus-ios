//
//  PromptContentViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 10/8/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import UIKit

protocol PromptContentViewControllerDelegate: class {
    func save(_ response: ReflectionResponse)
    func previousScreen()
    func handleTapGesture(touch: UITapGestureRecognizer)
    func nextScreen()
}

// Super Class for various Prompt Content cards
class PromptContentViewController: UIViewController {
    weak var delegate: PromptContentViewControllerDelegate?
    var content: Content!
    var promptContent: PromptContent!
    var tapNavigationEnabled = true
    var hasTextSelection = false
    var selectedTextView: UITextView?
    var logger = Logger("PromptContentViewController")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tapGestureHandler(touch:))))
    }
    
    @objc func tapGestureHandler(touch: UITapGestureRecognizer) {
        self.handleViewTapped(touch: touch)
    }
    
    func initTextView(_ textView: UITextView) {
        textView.delegate = self
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tapGestureHandler(touch:)))
        textView.addGestureRecognizer(tapRecognizer)
    }
    
    func handleViewTapped(touch: UITapGestureRecognizer) {
        if self.hasTextSelection, let textView = self.selectedTextView {
            textView.selectedTextRange = nil
        } else {
            if tapNavigationEnabled {
                self.delegate?.handleTapGesture(touch: touch)
            } else {
                self.logger.debug("Tap Navigation is disabled", functionName: #function)
            }
        }
    }
}

extension PromptContentViewController: UITextViewDelegate {
    func textViewDidChangeSelection(_ textView: UITextView) {
        self.hasTextSelection = textView.selectedTextRange != nil && !(textView.selectedTextRange?.isEmpty ?? false)
        if self.hasTextSelection {
            self.selectedTextView = textView
        }
    }
}
