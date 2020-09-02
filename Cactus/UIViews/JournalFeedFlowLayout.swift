//
//  JournalFeedFlowLayout.swift
//  Cactus
//
//  Created by Neil Poulin on 11/7/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import UIKit

class JournalFeedFlowLayout: UICollectionViewFlowLayout {

    override func invalidationContext(forPreferredLayoutAttributes preferredAttributes: UICollectionViewLayoutAttributes,
                                      withOriginalAttributes originalAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutInvalidationContext {
        let context = super.invalidationContext(forPreferredLayoutAttributes: preferredAttributes,
                                                withOriginalAttributes: originalAttributes)
        context.invalidateSupplementaryElements(ofKind: UICollectionView.elementKindSectionHeader,
                                                    at: [originalAttributes.indexPath])
        return context
    }
    
}
