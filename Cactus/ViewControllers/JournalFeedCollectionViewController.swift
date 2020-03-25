//
//  JournalFeedCollectionViewController.swift
//  Cactus Stage
//
//  Created by Neil Poulin on 7/26/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAnalytics
import SkeletonView

@IBDesignable
class JournalFeedCollectionViewController: UICollectionViewController {
    var dataSource: JournalFeedDataSource!
    var logger = Logger(fileName: "JournalFeedCollectionViewController")
    var memberUnsubscriber: Unsubscriber?
    var member: CactusMember?
    var headerView: UICollectionReusableView?
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
   
    func getCellEstimatedSize(_ size: CGSize) -> CGSize {
        let contentInsetWidth = self.collectionView.contentInset.left + self.collectionView.contentInset.right
        let width = min(760, size.width)
        return CGSize(width: width - sectionInsets.left - sectionInsets.right - contentInsetWidth, height: defaultCellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {

        // Get the view for the first header
        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)

        if self.member?.subscription?.isActivated == true {
            return CGSize.zero
        } else {
            // Use this view to calculate the optimal size based on the collection view's width
            return headerView.systemLayoutSizeFitting(CGSize(width: collectionView.frame.width, height: UIView.layoutFittingExpandedSize.height),
                                                      withHorizontalFittingPriority: .required, // Width is fixed
                                                      verticalFittingPriority: .fittingSizeLevel) // Height can be as large as needed
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()                                
        
        self.collectionView.prefetchDataSource = self
        layout.estimatedItemSize = getCellEstimatedSize(self.view.bounds.size)
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(self.appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(self.appMovedToBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        self.collectionView.reloadData()
        self.member = CactusMemberService.sharedInstance.currentMember
        self.memberUnsubscriber = CactusMemberService.sharedInstance.observeCurrentMember({ (member, error, _) in
            if let error = error {
                self.logger.error("Failed to get the current member", error)
                return
            }
            self.member = member
            DispatchQueue.main.async {
                _ = self.updateHeaderView()
                self.collectionViewLayout.invalidateLayout()
            }
        })
        
    }
    
    @IBAction func upgradeTapped(_ sender: Any) {
        learnMoreAboutUpgradeTapped(target: self)
    }
    
    func getHeaderView() -> UICollectionReusableView {
        if let view = self.headerView {
            return view
        }
        let kind = UICollectionView.elementKindSectionHeader
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: IndexPath(row: 0, section: 0))
        self.headerView = view
        return view
        
    }
    
    deinit {
        self.memberUnsubscriber?()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        layout.estimatedItemSize = getCellEstimatedSize(size)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    func reloadVisibleViews() {
        let visibleIds = self.collectionView.indexPathsForVisibleItems
        if  !visibleIds.isEmpty {
            self.logger.info("reloading visible ids \(visibleIds)")
            self.collectionView.reloadItems(at: visibleIds)
            self.collectionViewLayout.invalidateLayout()
        }
    }
    
    @objc func appMovedToForeground() {
        self.logger.debug("App moved to ForeGround!")
        self.reloadVisibleViews()
    }
    
    @objc func appMovedToBackground() {
        self.logger.debug("App Moved to background")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.collectionView.reloadData()
        self.setNeedsStatusBarAppearanceUpdate()
        self.reloadVisibleViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
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
//                vc.dismi
//                vc.dele
                let response = cell.responses?.first
                vc.reflectionResponse = response                
            }        
        default:
            break
        }
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func updateHeaderView() -> UICollectionReusableView {
        let headerView = self.getHeaderView()
        guard let upgradeView = headerView as? UpgradeJournalFeedCollectionReusableView else {
            return headerView
        }
        
        let member = self.member
        let isActivated = member?.subscription?.isActivated ?? false
        let inTrial = member?.subscription?.isInTrial ?? false
        let daysLeft = member?.subscription?.trialDaysLeft
        if isActivated {
            upgradeView.isHidden = true
            return upgradeView
        } else {
            upgradeView.isHidden = false
        }
        
        if inTrial {
            if daysLeft == 1 {
                upgradeView.titleLabel.text = "Trial ends today"
            } else {
                upgradeView.titleLabel.text = "\(daysLeft ?? 0) days left in trial"
            }
            
            upgradeView.descriptionLabel.text = SubscriptionService.sharedInstance.upgradeTrialDescription
        } else {
            upgradeView.titleLabel.text = "Cactus Plus"
            upgradeView.descriptionLabel.text = SubscriptionService.sharedInstance.upgradeBasicDescription
        }
        upgradeView.setNeedsLayout()
        return upgradeView
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            //handle the header
            return self.updateHeaderView()
        case UICollectionView.elementKindSectionFooter:
//            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Footer", for: indexPath)
//            let footerView = self.getHeaderView()
            
//            footerView.backgroundColor = UIColor.green
            
            assert(false, "Unexpected element kind for Footer")
            fatalError("Unexpeted element kind")
        default:
            //nothing to do
            logger.info("unexpected kind of supplemntry view")
//            return collectionView
            assert(false, "Unexpected element kind")
            fatalError("Unexpeted element kind")
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == self.dataSource.count - 1 {
            // Last cell is visible
            self.logger.info("Loading next page")
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
        journalCell.setCellWidth(self.getCellEstimatedSize(self.view.bounds.size).width)
        journalCell.delegate = self
        return journalCell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        guard let journalCell = cell as? JournalEntryCollectionViewCell else {
            return
        }
        
        if let promptContent =  journalCell.promptContent {
            Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                AnalyticsParameterContentType: "promptContent",
                AnalyticsParameterItemID: promptContent.promptId ?? ""
            ])
            
            self.performSegue(withIdentifier: "PromptContentCards", sender: cell)
        }
    }

}

extension JournalFeedCollectionViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        self.logger.info("Prefetch indexes called for \(indexPaths.map({$0.row}))")
        if indexPaths.contains(where: self.isLoadingCell) {
            self.dataSource.loadNextPage()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        self.logger.info("Cancel prefetching for \(indexPaths)")
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
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.collectionView.collectionViewLayout.invalidateLayout()
        }
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
