//
//  DetailViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 7/25/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import UIKit

@IBDesignable
class JournalEntryDetailViewController: UIViewController {
    var sentPrompt: SentPrompt?
    var responses: [ReflectionResponse]?
    var prompt: ReflectionPrompt?
    var contentLoading: Bool = false
    var promptContent: PromptContent?
    
    @IBOutlet weak var promptContentEntryIdLabel: UILabel!
    @IBOutlet weak var responseTextView: UITextView!
    @IBOutlet weak var promptContentText: UITextView!
    
    @IBOutlet weak var reflectButton: UIButton!
    @IBOutlet weak var questionLabel: UILabel!
    
    @IBAction func saveResponses(_ sender: Any) {
        var response = self.responses?.first
        
        self.view.dismissKeyboard()
        
        if response == nil, let promptId = self.prompt?.id {
            response = ReflectionResponseService.sharedInstance
                .createReflectionResponse(promptId, promptQuestion: self.prompt?.question)
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
        ReflectionResponseService.sharedInstance.save(toSave) { (saved, error) in
            if let error = error {
                print("Error fetching the saved reflection response", error)
            }
            print("Saved the response! \(saved?.id ?? "no id found")")
        }
        
    }
    
    func configureView() {
        questionLabel.text = self.prompt?.question ?? ""
        responseTextView.text = self.responses?.map {$0.content.text ?? ""}.joined(separator: "\n\n") ?? ""
        
        self.responseTextView.layer.borderColor = CactusColor.borderLight.cgColor
        self.responseTextView.layer.borderWidth = 1
        self.responseTextView.layer.cornerRadius = 6
        
        self.promptContentEntryIdLabel.text = self.prompt?.promptContentEntryId ?? "No Content"
        
        if self.contentLoading {
            self.promptContentText.text = "Loading Prompt Content..."
        }
        
        if let promptContent = self.promptContent {
            self.reflectButton.isHidden = false
            let videoIds = promptContent.content.first?.video?.fileIds.joined(separator: ", ")
            let videoId =  promptContent.content.first?.video?.fileId
            self.promptContentText.text = "\(promptContent.content.first?.text ?? "no id found") \n"
                + "FileIds: \(videoIds ?? "no video Ids")\nVideo File ID (computed) \(videoId ?? "none")"
        } else {
            self.reflectButton.isHidden = true
        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureView()
        self.view.setupKeyboardDismissRecognizer()
        
        if let prompt = self.prompt, let entryId = prompt.promptContentEntryId {
            self.contentLoading = true
            self.promptContentText.text = "Loading Prompt Content..."
            PromptContentService.sharedInstance.getByEntryId(id: entryId) { (content, error) in
                if let error = error {
                    print("Error getting entry by id", error)
                }
                
                print("Fetched prompt content from journal detail page!", String(describing: content))
                self.contentLoading = false
                self.promptContent = content
                
                self.configureView()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let segueId = segue.identifier
        
        switch segueId {
        case SegueID.ShowPromptContentModal.name:
            if let vc = segue.destination as? PromptContentPageViewController {
                vc.promptContent = self.promptContent
                vc.prompt = self.prompt
                var response = self.responses?.first
                if response == nil, let prompt = self.prompt {
                    response = ReflectionResponseService.sharedInstance.createReflectionResponse(prompt, medium: .PROMPT_IOS)
                }
                vc.reflectionResponse = response
            }
        default:
            print("No segue handled")
        }
    }
}
