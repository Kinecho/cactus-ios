//
//  JournalFeedCollectionViewController.swift
//  Cactus Stage
//
//  Created by Neil Poulin on 7/26/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import UIKit
import FirebaseFirestore

struct PromptData {
    var unsubscriber: ListenerRegistration?
    var prompt: ReflectionPrompt?
}

struct ResponseData {
    var unsubscriber: ListenerRegistration?
    var responses = [ReflectionResponse]()
}

struct ContentData {
    var unsubscriber: ListenerRegistration?
    var promptContent: PromptContent?
}

@IBDesignable
class JournalFeedCollectionViewController: UICollectionViewController {
    var promptListener: ListenerRegistration?
    var sentPrompts = [SentPrompt]()
    var hasLoaded = false
    
    var promptObserversById = [String: PromptData]()
    var responseObserversByPromptId = [String: ResponseData]()
    var contentObserversByPromptContentEntryId = [String: ContentData]()
    var currentMember: CactusMember?
    
    private let itemsPerRow: CGFloat = 1
    private let reuseIdentifier = ReuseIdentifier.JournalEntryCell.rawValue
    private let sectionInsets = UIEdgeInsets(top: 15.0,
                                             left: 15.0,
                                             bottom: 15.0,
                                             right: 15.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _ = CactusMemberService.sharedInstance.observeCurrentMember({ (member, error, _) in
            if self.currentMember != member {
                self.resetData()
            }
            
            self.currentMember = member
            if let member = member {
                self.promptListener = SentPromptService.sharedInstance
                    .observeSentPrompts(member: member, { (prompts, error) in
                        if let error = error {
                            print("Error observing prompts", error)
                        }
                        
                        print("Got sent prompts \(prompts?.count ?? 0)")
                        self.sentPrompts = prompts ?? []
                        self.hasLoaded = true
                        self.collectionView.reloadData()
                        
                        self.updateObservers()
                })
                
            }
        })
    }
    
    func resetData() {
        self.promptListener?.remove()
        self.sentPrompts.removeAll()
        self.promptObserversById.values.forEach { observer in
            observer.unsubscriber?.remove()
        }
        self.promptObserversById.removeAll()
        
        self.responseObserversByPromptId.values.forEach { (observer) in
            observer.unsubscriber?.remove()
        }
        self.responseObserversByPromptId.removeAll()
        
        self.contentObserversByPromptContentEntryId.values.forEach { (observer) in
            observer.unsubscriber?.remove()
        }
        self.contentObserversByPromptContentEntryId.removeAll()
        
        self.collectionView.reloadData()
    }
    
    @objc func showAccountPage(sender: Any) {
        AppDelegate.shared.rootViewController.pushScreen(ScreenID.MemberProfile, animate: true)
    }

    override func viewWillAppear(_ animated: Bool) { }
    
    func updateObservers() {
        self.sentPrompts.forEach { (sentPrompt) in
            guard let promptId = sentPrompt.promptId else {
                return
            }
            self.setupPromptObserver(promptId)
            self.setupResponseObserver(promptId)
        }
    }
    
    func setupContentObserver(_ entryId: String, promptId: String) {
        if self.contentObserversByPromptContentEntryId[entryId] != nil {
            return
        }
        
        var data = ContentData()
        PromptContentService.sharedInstance.getByEntryId(id: entryId) { (promptContent, error) in
            if let error = error {
                print("Failed to fetch prompt content by entryid", error)
            }
            
            data.promptContent = promptContent
            self.contentObserversByPromptContentEntryId[entryId] = data
            self.updateForPromptId(promptId)
        }
    }
    
    func setupPromptObserver(_ promptId: String) {
        if self.promptObserversById[promptId] != nil {
            return
        }
        var data = PromptData()
        data.unsubscriber = ReflectionPromptService.sharedInstance.observeById(id: promptId, { (prompt, error) in
            if let error = error {
                print("An error occurred while fetching ReflectionPromt ID = \(promptId)", error)
            }
            
            data.prompt = prompt
            self.promptObserversById[promptId] = data
            self.updateForPromptId(promptId)
            
            if let entryId = data.prompt?.promptContentEntryId {
                self.setupContentObserver(entryId, promptId: promptId)
            }
            
        })
    }
    
    func setupResponseObserver(_ promptId: String) {
        if self.responseObserversByPromptId[promptId] != nil {
            return
        }
        var data = ResponseData()
        data.unsubscriber = ReflectionResponseService.sharedInstance.observeForPromptId(id: promptId, { (responses, error) in
            if let error = error {
                print("An error occurred while fetching ReflectionPromt ID = \(promptId)", error)
            }
            data.responses = responses ?? []
            self.responseObserversByPromptId[promptId] = data
            self.updateForPromptId(promptId)
        })
    }

    func updateForPromptId(_ promptId: String) {
        let foundIndex = self.sentPrompts.firstIndex { (prompt) -> Bool in
            prompt.promptId == promptId
        }
        guard let index = foundIndex else {
            return
        }
        
        let indexPath = IndexPath(row: index, section: 0)
        self.collectionView.reloadItems(at: [indexPath])
    }

    @IBAction func showPromptContentCards(segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func showDetail(segue: UIStoryboardSegue) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "PromptContentCards":
            guard let cell = sender as? JournalEntryCollectionViewCell else {
                return
            }
            
            if let vc = segue.destination as? PromptContentPageViewController {
                vc.promptContent = cell.promptContent
                vc.prompt = cell.prompt
                var response = cell.responses?.first
                if response == nil, let prompt = cell.prompt {
                    response = ReflectionResponseService.sharedInstance.createReflectionResponse(prompt, medium: .PROMPT_IOS)
                }
                vc.reflectionResponse = response                
            }
            
        case "JournalEntryDetail":
//            let navWrapper = segue.destination as? UINavigationController
            guard let cell = sender as? JournalEntryCollectionViewCell else {
                return
            }
            let detailController = segue.destination as? JournalEntryDetailViewController
            detailController?.prompt = cell.prompt
            detailController?.responses = cell.responses
            detailController?.sentPrompt = cell.sentPrompt
            if let contentEntryId = cell.prompt?.promptContentEntryId {
                detailController?.promptContent = self.contentObserversByPromptContentEntryId[contentEntryId]?.promptContent
            }
        default:
            break
        }
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.sentPrompts.count
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        guard let journalCell = cell as? JournalEntryCollectionViewCell else {
            return cell
        }
        
        // Configure the cell
        let sentPrompt = sentPrompts[indexPath.row]
        journalCell.sentPrompt = sentPrompt
        if let promptId = sentPrompt.promptId {
            journalCell.responses = self.responseObserversByPromptId[promptId]?.responses
            journalCell.prompt = self.promptObserversById[promptId]?.prompt
            if let contentEntryId = journalCell.prompt?.promptContentEntryId {
                journalCell.promptContent = self.contentObserversByPromptContentEntryId[contentEntryId]?.promptContent
            }
            
        } else {
            journalCell.responses = nil
            journalCell.prompt = nil
            journalCell.promptContent = nil
        }
        
        journalCell.updateView()
        journalCell.addShadows()
        
        return journalCell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        guard let journalCell = cell as? JournalEntryCollectionViewCell else {
            return
        }
        
        if journalCell.promptContent != nil {
            self.performSegue(withIdentifier: "PromptContentCards", sender: cell)
        } else {
            self.performSegue(withIdentifier: "JournalEntryDetail", sender: cell)
        }
        // do stuff with image, or with other data that you need
    }
}

extension JournalFeedCollectionViewController: UICollectionViewDelegateFlowLayout {
    //1
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        //2
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: 200)
    }
    
    //3
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    // 4
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return sectionInsets.bottom
        return 45.0
    }
    
}
