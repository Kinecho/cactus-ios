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
    var logger = Logger(fileName: "JournalFeedCollectionViewController")
    private let itemsPerRow: CGFloat = 1
    private let reuseIdentifier = ReuseIdentifier.JournalEntryCell.rawValue
    private let defaultCellHeight: CGFloat = 220
    private let defaultPadding: CGFloat = 20
    private let defaultResponseTextHeight: CGFloat = 110
    private let sectionInsets = UIEdgeInsets(top: 15.0,
                                             left: 15.0,
                                             bottom: 15.0,
                                             right: 15.0)
    
    @IBOutlet weak var layout: JournalFeedFlowLayout!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            return .default
        }
    }
    
    func getCellEstimatedSize() -> CGSize {
        let contentInsetWidth = self.collectionView.contentInset.left + self.collectionView.contentInset.right
        return CGSize(width: self.view.bounds.size.width - sectionInsets.left - sectionInsets.right - contentInsetWidth, height: defaultCellHeight)
    }
 
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.prefetchDataSource = self
        layout.estimatedItemSize = getCellEstimatedSize()
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(self.appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(self.appMovedToBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        self.collectionView.reloadData()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    func reloadVisibleViews() {
        let visibleIds = self.collectionView.indexPathsForVisibleItems
        if  !visibleIds.isEmpty {
            print("reloading \(visibleIds)")
            self.collectionView.reloadItems(at: visibleIds)
        }
    }
    
    @objc func appMovedToForeground() {
        print("App moved to ForeGround!")
        self.reloadVisibleViews()
    }
    
    @objc func appMovedToBackground() {
        print("App Moved to background")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.collectionView.reloadData()
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
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
                vc.journalDataSource = self.dataSource
                var response = cell.responses?.first
                if response == nil, let prompt = cell.prompt {
                    response = ReflectionResponseService.sharedInstance.createReflectionResponse(prompt, medium: .PROMPT_IOS)
                }
                vc.reflectionResponse = response                
            }
            
        //depracated
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

    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == self.dataSource.count - 1 {
            // Last cell is visible
            print("Loading next page")
            DispatchQueue.main.async {
                self.dataSource.loadNextPage()
            }
        }
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
            // If no prompt content, don't do anything
            // self.performSegue(withIdentifier: "JournalEntryDetail", sender: cell)
        }
    }

}

extension JournalFeedCollectionViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        print("Prefetch indexes called for \(indexPaths.map({$0.row}))")
        if indexPaths.contains(where: self.isLoadingCell) {
            self.dataSource.loadNextPage()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        print("Cancel prefetchign for \(indexPaths)")
    }
    
    func isLoadingCell(for indexPath: IndexPath) -> Bool {
        return indexPath.row >= self.dataSource.count
    }
    
    func visibleIndexPathsToReload(intersecting indexPaths: [IndexPath]) -> [IndexPath] {
        let indexPathsForVisibleRows = self.collectionView.indexPathsForVisibleItems
        let indexPathsIntersection = Set(indexPathsForVisibleRows).intersection(indexPaths)
        return Array(indexPathsIntersection)
    }
    
}

extension JournalFeedCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 45.0
    }
}
extension JournalFeedCollectionViewController: JournalFeedDataSourceDelegate {
    func batchUpdate(addedIndexes: [Int], removedIndexes: [Int]) {
        self.collectionView.performBatchUpdates({
            self.collectionView.deleteItems(at: removedIndexes.map { IndexPath(row: $0, section: 0) })
            self.collectionView.insertItems(at: addedIndexes.map { IndexPath(row: $0, section: 0) })
        }, completion: { (completed) in
            self.logger.info("Batch update completed: \(completed)")
        })
    }
    
    func handleEmptyState(hasResults: Bool) {
        self.logger.warn("method not implemented", functionName: #function)
    }
    
    func updateEntry(_ journalEntry: JournalEntry, at: Int?) {
        guard let index = at else {
            self.logger.warn("Unable to update entry: Index not provided", functionName: #function)
            return
        }
        let indexPath = IndexPath(row: index, section: 0)
        self.logger.debug("Updating entry at \(indexPath)", functionName: #function)
        self.collectionView.reloadItems(at: [indexPath])
    }
    
    func dataLoaded() {
        self.logger.info("JournalFeed Delegate: Data Loaded: reloading Data on collection view", functionName: #function)
        self.collectionView.reloadData()
    }
    
    func insert(_ journalEntry: JournalEntry, at: Int?) {
        guard let index = at ?? self.dataSource.indexOf(journalEntry) else {
            self.logger.warn("unable to find index of journal entry \(journalEntry)", functionName: #function)
            return
        }
        self.logger.info("Inserting data at \(index)", functionName: #function)
        let indexPath = IndexPath(row: index, section: 0)
        self.collectionView.insertItems(at: [indexPath])        
    }
    
    func removeItems(_ indexes: [Int]) {
        self.logger.info("Removing items at \(indexes)", functionName: #function)
        let indexPaths = indexes.map { IndexPath(row: $0, section: 0) }
        self.collectionView.deleteItems(at: indexPaths)
    }
    
    func insertItems(_ indexes: [Int]) {
        self.logger.info("Inserting items at \(indexes)", functionName: #function)
        let indexPaths = indexes.map { IndexPath(row: $0, section: 0) }
        self.collectionView.insertItems(at: indexPaths)
    }    
}

extension JournalFeedCollectionViewController: JournalEntryCollectionVieweCellDelegate {
    func goToDetails(cell: UICollectionViewCell) {
        guard let path = self.collectionView.indexPath(for: cell) else {return}
        self.collectionView.delegate?.collectionView?(self.collectionView, didSelectItemAt: path)
    }
}
