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
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tapGestureHandler(touch:)))
//        self.view.isUserInteractionEnabled = true
//        self.view.addGestureRecognizer(tapRecognizer)
//        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tapGestureHandler(touch:)))
//        tapRecognizer.isEnabled = true
//        self.view.addGestureRecognizer(tapRecognizer)
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tapGestureHandler(touch:))))
        // Do any additional setup after loading the view.
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
                print("Tap Navigation is disabled")
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension PromptContentViewController: UITextViewDelegate {
    func textViewDidChangeSelection(_ textView: UITextView) {
        self.hasTextSelection = textView.selectedTextRange != nil && !(textView.selectedTextRange?.isEmpty ?? false)
        if self.hasTextSelection {
            self.selectedTextView = textView
        }
    }
}
