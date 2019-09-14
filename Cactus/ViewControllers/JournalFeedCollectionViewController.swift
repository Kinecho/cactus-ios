//
//  JournalFeedCollectionViewController.swift
//  Cactus Stage
//
//  Created by Neil Poulin on 7/26/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import UIKit
import FirebaseFirestore
private let reuseIdentifier = "Cell"

struct PromptData {
    var unsubscriber: ListenerRegistration?
    var prompt: ReflectionPrompt?
}

struct ResponseData {
    var unsubscriber: ListenerRegistration?
    var responses = [ReflectionResponse]()
}

class JournalFeedCollectionViewController: UICollectionViewController {
    var promptListener: ListenerRegistration?
    var sentPrompts = [SentPrompt]()
    var hasLoaded = false
    
    var promptObserversById = [String: PromptData]()
    var responseObserversByPromptId = [String: ResponseData]()
    var currentMember: CactusMember?
    
    private let itemsPerRow: CGFloat = 1
    private let reuseIdentifier = "JournalEntryCell"
    private let sectionInsets = UIEdgeInsets(top: 15.0,
                                             left: 20.0,
                                             bottom: 15.0,
                                             right: 20.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _ = CactusMemberService.sharedInstance.observeCurrentMember({ (member, error) in
            if self.currentMember != member {
                self.resetData()
            }
            
            self.currentMember = member
            if let member = member {
                print("Got current cactus member \(member.email ?? "No Email found" ) - \(member.id ?? "not found")")
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "JournalEntryDetail":
//            let navWrapper = segue.destination as? UINavigationController
            guard let cell = sender as? JournalEntryCollectionViewCell else {
                return
            }
            let detailController = segue.destination as? JournalEntryDetailViewController
            detailController?.prompt = cell.prompt
            detailController?.responses = cell.responses
            detailController?.sentPrompt = cell.sentPrompt
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
        } else {
            journalCell.responses = nil
            journalCell.prompt = nil
        }
        
        journalCell.updateView()
        
        return journalCell
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
        return sectionInsets.left
    }
    
}
