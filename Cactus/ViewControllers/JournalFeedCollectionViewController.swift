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
//        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(self.appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(self.appMovedToBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        self.collectionView.reloadData()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

//        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    @IBAction func loadMoreTapped(_ sender: Any) {
        self.dataSource.loadNextPage()
    }
    
    @objc func appMovedToForeground() {
        print("App moved to ForeGround!")
        DispatchQueue.main.async {
            self.dataSource.checkForNewPrompts()
        }
        
//        self.collectionView.layoutIfNeeded()
//        self.layout.invalidateLayout()
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
            self.performSegue(withIdentifier: "JournalEntryDetail", sender: cell)
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
    func updateEntry(_ journalEntry: JournalEntry, at: Int?) {
//        print("Update feed for entry at \(at ?? -1)")
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
    
    func insert(_ journalEntry: JournalEntry, at: Int?) {
        guard let index = at ?? self.dataSource.indexOf(journalEntry) else {
            print("unable to find index of journal entry")
            return
        }
        
        let indexPath = IndexPath(row: index, section: 0)
        self.collectionView.insertItems(at: [indexPath])        
    }
    
    func insertItems(_ indexes: [Int]) {
        let indexPaths = indexes.map { IndexPath(row: $0, section: 0) }
        self.collectionView.insertItems(at: indexPaths)
    }
    
    func loadingCompleted() {
//        self.collectionView.layoutIfNeeded()
    }
}

extension JournalFeedCollectionViewController: JournalEntryCollectionVieweCellDelegate {
    func goToDetails(cell: UICollectionViewCell) {
        guard let path = self.collectionView.indexPath(for: cell) else {return}
        self.collectionView.delegate?.collectionView?(self.collectionView, didSelectItemAt: path)
    }
}
