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

    var promptListener:ListenerRegistration?
    var sentPrompts = [SentPrompt]()
    var hasLoaded = false
    
    var promptObserversById = [String: PromptData]()
    var responseObserversByPromptId = [String: ResponseData]()
    
    
    private let itemsPerRow:CGFloat = 1
    private let reuseIdentifier = "JournalEntryCell"
    private let sectionInsets = UIEdgeInsets(top: 15.0,
                                             left: 20.0,
                                             bottom: 15.0,
                                             right: 20.0)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
//        self.collectionView!.register(JournalEntryCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        
        guard let member = CactusMemberService.sharedInstance.getCurrentMember() else {
            print("No cactus member found")
            return
        }
        print("Got current cactus member \(member.email ?? "No Email found" ) - \(member.id ?? "not found")")
        
        self.promptListener = SentPromptService.sharedInstance.observeSentPrompts(member: member, { (prompts, error) in
            print("Got sent prompts \(prompts?.count ?? 0)")
            self.sentPrompts = prompts ?? []
            self.hasLoaded = true
            self.collectionView.reloadData()
            
            self.updateObservers();
        })
    }
    
    func updateObservers() {
        self.sentPrompts.forEach { (sentPrompt) in
            guard let promptId = sentPrompt.promptId else {
                return
            }
            self.setupPromptObserver(promptId)
            self.setupResponseObserver(promptId)
        }
    }
    
    func setupPromptObserver(_ promptId:String){
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
            print("Got Reflection prompt for PromptId \(promptId), \(prompt?.question ?? "No Question Found")")
            self.updateForPromptId(promptId)
            
        })
    }
    
    func setupResponseObserver(_ promptId: String){
        if self.responseObserversByPromptId[promptId] != nil {
            return
        }
        var data = ResponseData()
        data.unsubscriber = ReflectionResponseService.sharedInstance.observeForPromptId(id: promptId, { (responses, error) in
            if let error = error {
                print("An error occurred while fetching ReflectionPromt ID = \(promptId)", error)
            }
            print("Got Responses for PromptId \(promptId) size: \(responses?.count ?? 0)")
            data.responses = responses ?? []
            self.responseObserversByPromptId[promptId] = data
            self.updateForPromptId(promptId)
        })
    }

    func updateForPromptId(_ promptId:String){
        let foundIndex = self.sentPrompts.firstIndex { (prompt) -> Bool in
            prompt.promptId == promptId
        }
        guard let index = foundIndex else {
            return
        }
        
        let indexPath = IndexPath(row: index, section: 0)
        self.collectionView.reloadItems(at: [indexPath])
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        
        let cell = sender as! JournalEntryCollectionViewCell

        
        switch (segue.identifier){
        case "JournalEntryDetail":
            let navWrapper = segue.destination as? UINavigationController
            let detailController = navWrapper?.topViewController as? JournalEntryDetailViewController
            detailController?.prompt = cell.prompt
            detailController?.responses = cell.responses
            detailController?.sentPrompt = cell.sentPrompt
            
            break;
        default:
            break;
        }
        
    }


    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.sentPrompts.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! JournalEntryCollectionViewCell
    
        // Configure the cell
        let sentPrompt = sentPrompts[indexPath.row]
        cell.sentPrompt = sentPrompt
        if let promptId = sentPrompt.promptId  {
            cell.responses = self.responseObserversByPromptId[promptId]?.responses
            cell.prompt = self.promptObserversById[promptId]?.prompt
        } else {
            cell.responses = nil
            cell.prompt = nil
        }
        
        cell.updateView()
        
//        cell.dateLabel =  sentPrompt.lastSentAt
        
        return cell
    }

    
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}

extension JournalFeedCollectionViewController : UICollectionViewDelegateFlowLayout {
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
