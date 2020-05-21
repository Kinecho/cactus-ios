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
    var editViewController: EditReflectionViewController?
    var settings: AppSettings? {
        didSet {
            self.handleSettingsChanged()
        }
    }
    var settingsListener: ListenerRegistration?
    weak var promptContentDelegate: PromptContentPageViewControllerDelegate?
    
    private let itemsPerRow: CGFloat = 1
    //    private let reuseIdentifier = ReuseIdentifier.JournalEntryCell.rawValue
    private let defaultCellHeight: CGFloat = 220
    private let defaultPadding: CGFloat = 20
    private let defaultResponseTextHeight: CGFloat = 110
    private let sectionInsets = UIEdgeInsets(top: 15.0,
                                             left: 15.0,
                                             bottom: 15.0,
                                             right: 15.0)
    
    @IBOutlet weak var layout: JournalFeedFlowLayout!
    
    let reuseIdentifier = "JournalEntryCell"
    
    func getCellEstimatedSize(_ size: CGSize) -> CGSize {
        let contentInsetWidth = self.collectionView.contentInset.left + self.collectionView.contentInset.right
        let width = min(760, size.width)
        return CGSize(width: width - sectionInsets.left - sectionInsets.right - contentInsetWidth, height: defaultCellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)
        if self.member?.subscription?.isActivated == true {
            logger.info("size is 0")
            return CGSize.zero
        } else {
            // Use this view to calculate the optimal size based on the collection view's width
            let layoutSize = headerView.systemLayoutSizeFitting(CGSize(width: collectionView.frame.width,
                                                                       height: UIView.layoutFittingExpandedSize.height),
                                                                withHorizontalFittingPriority: .required, // Width is fixed
                verticalFittingPriority: .fittingSizeLevel) // Height can be as large as needed
            logger.info("header view height is \(layoutSize.height)")
            return layoutSize
        }
        
    }
    
    //    func getCellWidth() -> CGFloat {
    //           let screenWidth = UIScreen.main.bounds.size.width
    //        var width: CGFloat = screenWidth - self.sectionInsets.left - self.sectionInsets.right
    //
    //           if screenWidth > 500 {
    //            width = (screenWidth/2) - self.sectionInsets.left - self.sectionInsets.right
    //           }
    //           return width
    //       }
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        self.settingsListener = AppSettingsService.sharedInstance.observeSettings({ (settings, _) in
            self.logger.info("GOT APP SETTINGS \(String(describing: settings))")
            self.settings = settings
        })
        
        self.collectionView.register(UINib(nibName: "JournalEntryCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        
        self.collectionView.prefetchDataSource = self
        //        layout.estimatedItemSize = getCellEstimatedSize(self.view.bounds.size)
        
        self.view.translatesAutoresizingMaskIntoConstraints = false
        if let flowLayout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = getCellEstimatedSize(self.view.bounds.size)
        }
        self.view.translatesAutoresizingMaskIntoConstraints = false
        
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
                self.logger.info("Updating header due to member changed")
                _ = self.updateHeaderView()
            }
        })
        
    }
    
    func handleSettingsChanged() {
        DispatchQueue.main.async {
            self.logger.info("Updating header due to settings changed")
            _ = self.updateHeaderView()
        }
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
        self.settingsListener?.remove()
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
    
    
    @IBAction func showPromptContentCards(segue: UIStoryboardSegue) { }
    @IBAction func showDetail(segue: UIStoryboardSegue) { }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "PromptContentCards":
            guard let cell = sender as? JournalEntryCell else {
                return
            }
            
            if let vc = segue.destination as? PromptContentPageViewController {
                vc.promptContent = cell.promptContent
                vc.promptDelegate = self.promptContentDelegate
                
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
        
        DispatchQueue.main.async {
            upgradeView.member = self.member
            upgradeView.appSettings = self.settings
            upgradeView.updateCopy()
            upgradeView.setNeedsLayout()
            self.collectionView.collectionViewLayout.invalidateLayout()
        }
        
        return upgradeView
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = self.getHeaderView()
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            return view
        default:
            view.isHidden = true
            return view
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
        //        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        //        guard let journalCell = cell as? JournalEntryCollectionViewCell else {
        //            return cell
        //        }
        //
        //        let journalEntry = self.dataSource.get(at: indexPath.row)
        //        journalCell.journalEntry = journalEntry
        //        journalCell.updateView()
        //        journalCell.setCellWidth(self.getCellEstimatedSize(self.view.bounds.size).width)
        //        journalCell.delegate = self
        //        return journalCell
        
        let _cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        let cellWidth = self.getCellEstimatedSize(self.view.bounds.size).width
        guard let cell = _cell as? JournalEntryCell else {
            return _cell
        }
        let journalEntry = self.dataSource.get(at: indexPath.row)
        cell.delegate = self
        cell.setWidth(cellWidth)
        cell.data = journalEntry
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        guard let journalCell = cell as? JournalEntryCell else {
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
    
    func presentEditReflectionModal(_ data: JournalEntry) -> EditReflectionViewController? {
        let editView = EditReflectionViewController.loadFromNib()
        editView.delegate = self
        
        var response = data.responses?.first
        let coreValue = data.responses?.first {$0.coreValue != nil }?.coreValue
        let questionText = data.promptContent?.getDisplayableQuestion(member: member, coreValue: coreValue) ?? data.prompt?.question
                
        if response == nil, let promptId = data.sentPrompt?.promptId {
            let element = data.promptContent?.cactusElement
            
            response = ReflectionResponseService.sharedInstance.createReflectionResponse(promptId, promptQuestion: questionText, element: element, medium: .JOURNAL_IOS)            
        }
        
        guard let reflectionResponse = response else {
            return nil
        }
        
        editView.response = reflectionResponse
        editView.questionText = questionText
        
        self.editViewController = editView
        NavigationService.sharedInstance.present(editView, animated: true)
        
        return editView
    }
    
    func done(text: String?, response: ReflectionResponse?) {
        guard let response = response else {
            self.editViewController?.dismiss(animated: true, completion: nil)
            return
        }
        
        response.content.text = text
        //            self.reloadVisibleViews()
        
        ReflectionResponseService.sharedInstance.save(response) { (saved, error) in
            self.logger.debug("Saved the response! \(saved?.id ?? "no id found")")
            self.editViewController?.isSaving = false
            if error == nil {
                self.editViewController?.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func cancel() {
        self.editViewController?.dismiss(animated: true, completion: nil)
    }
    
}
