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
    var descriptionText: String?
    
    init(_ element: CactusElement) {
        self.element = element
        self.title = element.title
        self.image = element.getImage()
        self.descriptionText = element.description
    }
}

class BrowseElementsCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let elementEntries: [ElementEntry] = CactusElement.allCases.map { ElementEntry($0) }
    
    let cellIdentifier = "ElementCell"
//    let cellWidth:CGFloat = 200
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.register(UINib(nibName: "ElementCell", bundle: .main), forCellWithReuseIdentifier: cellIdentifier)
        if let flowLayout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
//            flowLayout.estimatedItemSize = CGSize(width: 300, height: 150)
            flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize

        }
        self.view.translatesAutoresizingMaskIntoConstraints = false

        self.collectionView.dataSource = self
        
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? ElementCell else {
            return collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
        }
        cell.translatesAutoresizingMaskIntoConstraints = false
        
        let entry = self.elementEntries[indexPath.row]
//        cell.configure()
        cell.elementEntry = entry
        return cell
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.elementEntries.count
    }
        
}
