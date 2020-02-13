//
//  SubscriptionProductCollectionViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 2/7/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import UIKit
import StoreKit

private let reuseIdentifier = "SubscriptionProductCell"

struct SubscriptionProductEntry {
    let skProduct: SKProduct
    let subscriptionProduct: SubscriptionProduct
    
    init(subscriptionProduct: SubscriptionProduct, skProduct: SKProduct) {
        self.skProduct = skProduct
        self.subscriptionProduct = subscriptionProduct
    }
}

class SubscriptionProductCollectionViewController: UICollectionViewController {
    
    @IBOutlet weak var layout: UICollectionViewFlowLayout!
    private let defaultCellHeight: CGFloat = 220
    private let defaultPadding: CGFloat = 20
    private let sectionInsets = UIEdgeInsets(top: 15.0,
                                             left: 15.0,
                                             bottom: 15.0,
                                             right: 15.0)
    
    var dataSource: [SubscriptionProductEntry] = [] {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layout.estimatedItemSize = getCellEstimatedSize(self.view.bounds.size)
        // Uncomment the following line to preserve selection between presentations
         self.clearsSelectionOnViewWillAppear = true

        // Register cell classes
//        self.collectionView!.register(SubscriptionProductCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.reloadData()
    }

    func getCellEstimatedSize(_ size: CGSize) -> CGSize {
           let contentInsetWidth = self.collectionView.contentInset.left + self.collectionView.contentInset.right
           let width = min(760, size.width)
           return CGSize(width: width - sectionInsets.left - sectionInsets.right - contentInsetWidth, height: defaultCellHeight)
       }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataSource.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let _cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        guard let cell = _cell as? SubscriptionProductCell else {
            return _cell
        }
        // Configure the cell
        let entry = self.dataSource[indexPath.row]
        
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = entry.skProduct.priceLocale
        
        cell.title.text = entry.subscriptionProduct.displayName
        cell.priceLabel.text = currencyFormatter.string(from: entry.skProduct.price)
    
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
