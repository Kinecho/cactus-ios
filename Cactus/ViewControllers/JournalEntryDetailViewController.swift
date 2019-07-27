//
//  DetailViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 7/25/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import UIKit

class JournalEntryDetailViewController: UIViewController {
    var sentPrompt:SentPrompt?
    var responses: [ReflectionResponse]?
    var prompt: ReflectionPrompt?
    
    @IBOutlet weak var responseTextView: UITextView!
    
    @IBOutlet weak var questionLabel: UILabel!
    
    @IBAction func saveResponses(_ sender: Any) {
        var response = self.responses?.first
        
        self.view.dismissKeyboard()
        
        if response == nil, let promptId = self.prompt?.id {
            response = ReflectionResponseService.sharedInstance.createReflectionResponse(promptId, promptQuestion: self.prompt?.question)
        }
        
        response?.content.text = self.responseTextView.text
        
        self.responses?.forEach{ r in
            if r.id != response?.id {
                ReflectionResponseService.sharedInstance.delete(r, { (error) in
                    if let error = error {
                        print("failed to delete reflection response \(r.id ?? "id unknown")", error)
                    }
                    else {
                        print("Successfully deleted reflection response")
                    }
                })
            }
        }
        
        guard let toSave = response else {
            print("No response found while trying to save... exiting")
            return
        }
        ReflectionResponseService.sharedInstance.save(toSave) { (saved, error) in
            print("Saved the response! \(saved?.id ?? "no id found")")
        }
        
    }
    
    func configureView() {
        questionLabel.text = self.prompt?.question ?? ""
        responseTextView.text = self.responses?.map{$0.content.text ?? ""}.joined(separator: "\n\n") ?? ""
        
        self.responseTextView.layer.borderColor = CactusColor.borderLight.cgColor
        self.responseTextView.layer.borderWidth = 1
        self.responseTextView.layer.cornerRadius = 6
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureView()
        self.view.setupKeyboardDismissRecognizer()
        
        
    }

    

}

