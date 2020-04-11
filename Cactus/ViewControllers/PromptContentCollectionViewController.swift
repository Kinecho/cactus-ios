//
//  PromptContentCollectionViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 4/10/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class PromptContentCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    let logger = Logger("PromptContentCollectionViewController")
    var element: CactusElement!
    let margin: CGFloat = 20
    var dataSource: PromptContentDataSource!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = PromptContentDataSource.forElement(self.element)
        self.dataSource.delegate = self
        
        self.collectionView.register(UINib(nibName: "PromptEntryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        
        if let flowLayout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = CGSize(width: self.getCellWidth(), height: 500)
        }
        self.view.translatesAutoresizingMaskIntoConstraints = false
        self.navigationItem.title = self.element.title
        self.collectionView.dataSource = self
        
        self.collectionView.reloadData()
    }
    
    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return self.dataSource.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? PromptEntryCollectionViewCell else {
            return collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        }
            
        // Configure the cell
        let data = self.dataSource.get(index: indexPath.row)
        cell.data = data
        cell.margin = self.margin
        cell.setWidth(self.getCellWidth())
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    //    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    //        let row = indexPath.row
    //
    //    }
    
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
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.showPrompt(data: self.dataSource.get(index: indexPath.row))
    }
    
    func showPrompt(data: PromptContentData?) {
        guard let promptContent = data?.promptContent else {
            return
        }
        
        guard let vc = ScreenID.promptContentPageView.getViewController() as? PromptContentPageViewController else {return}
        vc.promptContent = promptContent
        vc.reflectionResponse = data?.responseData.responses.first
        
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .coverVertical
        self.present(vc, animated: true, completion: nil)
    }
    
    func getCellWidth() -> CGFloat {
        let screenWidth = UIScreen.main.bounds.size.width
        var width: CGFloat = screenWidth - (2 * margin)
        
        if screenWidth > 400 {
            width = (screenWidth/2) - (2 * margin)
        }
        return width
    }
}

extension PromptContentCollectionViewController: PromptContentDataSourceDelegate {
    func batchUpdate(addedIndexes: [Int], updatedIndexes: [Int], removedIndexes: [Int]) {
        self.logger.info("Batch update added: \(addedIndexes) | updated: \(updatedIndexes) | removed: \(removedIndexes)")
        DispatchQueue.main.async {
            self.collectionView.performBatchUpdates({
                self.collectionView.deleteItems(at: removedIndexes.map { IndexPath(row: $0, section: 0) })
                self.collectionView.insertItems(at: addedIndexes.map { IndexPath(row: $0, section: 0) })
                self.collectionView.reloadItems(at: updatedIndexes.map { IndexPath(row: $0, section: 0) })
            }, completion: { _ in
                
            })
        }
    }
}
