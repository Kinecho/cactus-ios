//
//  BrowseElementsViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 4/9/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import UIKit

class ElementEntry {
    var title: String
    var image: UIImage?
    var element: CactusElement
    var description: String
    
    init(_ element: CactusElement) {
        self.title = element.title
        self.image = element.getImage()
        self.element = element
        self.description = element.description
    }
}

class BrowseElementsCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    let elementEntries: [ElementEntry] = CactusElement.elementsAlphabetical.map { ElementEntry($0) }
    let cellIdentifier = "ElementCell"
    let margin: CGFloat = 20
    var member: CactusMember? {
        CactusMemberService.sharedInstance.currentMember
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.register(UINib(nibName: "ElementCell", bundle: .main), forCellWithReuseIdentifier: cellIdentifier)
        self.view.translatesAutoresizingMaskIntoConstraints = false
        if let flowLayout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = CGSize(width: self.getCellWidth(), height: 200)
        }
        self.view.translatesAutoresizingMaskIntoConstraints = false
        self.collectionView.dataSource = self
        self.collectionView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? ElementCell else {
            return collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
        }
        
        let entry = self.elementEntries[indexPath.row]
        cell.elementEntry = entry
        cell.margin = self.margin
        cell.setWidth(self.getCellWidth())
        return cell
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.elementEntries.count
    }
        
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let row = indexPath.row
        let entry = self.elementEntries[row]
        guard self.member?.tier.isPaidTier == true else {
            let pricingVc = ScreenID.Pricing.getViewController()
            self.present(pricingVc, animated: true)
            return
        }
        guard let vc = ScreenID.PromptContentCollection.getViewController() as? PromptContentCollectionViewController else {
            return
        }
        vc.element = entry.element
        CactusAnalytics.shared.logBrowseElementSelected(entry.element)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: self.getCellWidth(), height: 200)
//    }
    
    func getCellWidth() -> CGFloat {
        let screenWidth = UIScreen.main.bounds.size.width
        var width: CGFloat = screenWidth - (2 * margin)
        
        if screenWidth > 500 {
            width = (screenWidth/2) - (2 * margin)
        }
        return width
    }
}
