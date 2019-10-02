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
    var dataSource: JournalFeedDataSource!
    
    private let itemsPerRow: CGFloat = 1
    private let reuseIdentifier = ReuseIdentifier.JournalEntryCell.rawValue
    private let defaultCellHeight: CGFloat = 220
    private let defaultPadding: CGFloat = 20
    private let defaultResponseTextHeight: CGFloat = 110
    private let sectionInsets = UIEdgeInsets(top: 15.0,
                                             left: 15.0,
                                             bottom: 15.0,
                                             right: 15.0)
    
    @IBOutlet weak var layout: UICollectionViewFlowLayout!
    func getCellEstimatedSize() -> CGSize {
        let contentInsetWidth = self.collectionView.contentInset.left + self.collectionView.contentInset.right
        return CGSize(width: self.view.bounds.size.width - sectionInsets.left - sectionInsets.right - contentInsetWidth, height: defaultCellHeight)
    }
 
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.dataSource.delegate = self
        layout.estimatedItemSize = getCellEstimatedSize()
    }
    
    @objc func showAccountPage(sender: Any) {
        AppDelegate.shared.rootViewController.pushScreen(ScreenID.MemberProfile, animate: true)
    }

    override func viewWillAppear(_ animated: Bool) { }
    
    @IBAction func showPromptContentCards(segue: UIStoryboardSegue) { }
    @IBAction func showDetail(segue: UIStoryboardSegue) { }
    
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
        return self.dataSource.count
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        guard let journalCell = cell as? JournalEntryCollectionViewCell else {
            return cell
        }
                
        let journalEntry = self.dataSource.get(at: indexPath.row)

        print("Updating cell for \(indexPath.row). promptId=\(journalEntry?.sentPrompt.promptId ?? "not set")")
        journalCell.journalEntry = journalEntry
        journalCell.updateView()
        journalCell.setCellWidth(self.getCellEstimatedSize().width)
        journalCell.delegate = self
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
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 45.0
    }
    
    private func estimateFrameForText(text: String, width: CGFloat, font: UIFont = CactusFont.normal) -> CGRect {
        //we make the height arbitrarily large so we don't undershoot height in calculation
        let height: CGFloat = 5000
    
        let size = CGSize(width: width, height: height)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
       
        let attributes = [NSAttributedString.Key.font: font]

        return NSString(string: text).boundingRect(with: size, options: options, attributes: attributes, context: nil)
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
    
    func loadingCompleted() {
        //        
    }
}

extension JournalFeedCollectionViewController: JournalEntryCollectionVieweCellDelegate {
    func goToDetails(cell: UICollectionViewCell) {
        guard let path = self.collectionView.indexPath(for: cell) else {return}
        self.collectionView.delegate?.collectionView?(self.collectionView, didSelectItemAt: path)
    }
}
