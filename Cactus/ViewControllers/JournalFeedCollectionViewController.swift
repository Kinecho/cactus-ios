//
//  JournalFeedCollectionViewController.swift
//  Cactus Stage
//
//  Created by Neil Poulin on 7/26/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import UIKit
import FirebaseFirestore
import SkeletonView

@IBDesignable
class JournalFeedCollectionViewController: UICollectionViewController {
    static var dataSource: JournalFeedDataSource = JournalFeedDataSource()
    
    private let itemsPerRow: CGFloat = 1
    private let reuseIdentifier = ReuseIdentifier.JournalEntryCell.rawValue
    private let sectionInsets = UIEdgeInsets(top: 15.0,
                                             left: 15.0,
                                             bottom: 15.0,
                                             right: 15.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        JournalFeedCollectionViewController.dataSource.delegate = self
        
        if let layout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = UICollectionViewFlowLayout.automaticSize
            layout.estimatedItemSize = CGSize(width: self.view.bounds.size.width - sectionInsets.left - sectionInsets.right, height: 220)
        }
    }
    
    @objc func showAccountPage(sender: Any) {
        AppDelegate.shared.rootViewController.pushScreen(ScreenID.MemberProfile, animate: true)
    }

    override func viewWillAppear(_ animated: Bool) { }
    
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
            detailController?.promptContent = cell.promptContent
        default:
            break
        }
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return JournalFeedCollectionViewController.dataSource.count
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        guard let journalCell = cell as? JournalEntryCollectionViewCell else {
            return cell
        }
                
        let journalEntry = JournalFeedCollectionViewController.dataSource.get(at: indexPath.row)
        // Configure the cell
//        let sentPrompt = journalEntry?.sentPrompt
//        if journalEntry != journalCell.journalEntry {
//
//        }
        print("Updating cell for \(indexPath.row). promptId=\(journalEntry?.sentPrompt.promptId ?? "not set")")
        journalCell.journalEntry = journalEntry
        journalCell.updateView()
        
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
//    //1
//    func collectionView(_ collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        sizeForItemAt indexPath: IndexPath) -> CGSize {
//        //2
//        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
//        let internalPadding: CGFloat = 20
//        let availableWidth = view.frame.width - paddingSpace
//        let widthPerItem = availableWidth / itemsPerRow
//        let approximateWidthOfContents = self.view.frame.width - paddingSpace - (2 * internalPadding)
//        print("approximage width of contents \(approximateWidthOfContents)")
//
//        let topSpace: CGFloat = 24
//        let bottomSpace: CGFloat = 20
//        let dateHeight: CGFloat = 21
//        let dateBottomMargin: CGFloat = 18
//        let questionBottomMargin: CGFloat = 12
//        let baseHeight: CGFloat = topSpace + bottomSpace + dateHeight + dateBottomMargin + questionBottomMargin
//        var responseHeight: CGFloat = 30
//        var questionHeight: CGFloat = 25
//        //get an estimation of height of cell based on content
//        if let cell = collectionView.cellForItem(at: indexPath) as? JournalEntryCollectionViewCell {
//            if let responseText = FormatUtils.responseText(cell.responses) {
//                let size = CGSize(width: approximateWidthOfContents, height: 1000) //use arbitrarily large height
//                let attributes = [NSAttributedString.Key.font: CactusFont.normal]
//                let estimatedResponseFrame = NSString(string: responseText )
//                    .boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
//                print("estimated response height is \(estimatedResponseFrame.height)")
//                responseHeight = estimatedResponseFrame.height + 12
////                return CGSize(width: widthPerItem, height: estimatedResponseFrame.height)
//            }
//
//            if let questionText = cell.prompt?.question {
//                let size = CGSize(width: approximateWidthOfContents, height: 1000) //use arbitrarily large height
//                let attributes = [NSAttributedString.Key.font: CactusFont.large]
//                let estimatedResponseFrame = NSString(string: questionText )
//                    .boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
//                print("estimated question height is \(estimatedResponseFrame.height) for question \(questionText)")
//                questionHeight = estimatedResponseFrame.height + 6
//            }
//
//        }
//
//        return CGSize(width: widthPerItem, height: baseHeight + responseHeight + questionHeight )
//    }
//
    //3
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
//
    // 4
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return sectionInsets.bottom
        return 45.0
    }
}

extension JournalFeedCollectionViewController: JournalFeedDataSourceDelegate {
    func updateEntry(_ journalEntry: JournalEntry, at: Int?) {
        print("Update feed for entry at \(at ?? -1)")
        guard let index = at else {
            return
        }
        let indexPath = IndexPath(row: index, section: 0)
        self.collectionView.reloadItems(at: [indexPath])
    }
    
    func dataLoaded() {
        print("JournalFeed Delegate: Data Loaded: Updating collection view cells")
        self.collectionView.reloadData()
    }
}
