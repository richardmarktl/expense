//
//  FullWidthLayout.swift
//  habi
//
//  Created by Georg Kitz on 22.04.19.
//  Copyright © 2019 Georg Kitz. All rights reserved.
//

import UIKit

class FullWidthFlowLayout: UICollectionViewFlowLayout {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        itemSize = UICollectionViewFlowLayout.automaticSize

    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let layoutAttributes = super.layoutAttributesForItem(at: indexPath) else {
            return nil
        }
        guard let collectionView = collectionView else {
            return nil
        }
        print("\(layoutAttributes), \(indexPath)")
        layoutAttributes.bounds.size.width = collectionView.safeAreaLayoutGuide.layoutFrame.width - sectionInset.left - sectionInset.right
        layoutAttributes.frame.origin.x = sectionInset.left
        print("\(layoutAttributes), \(indexPath)")
        return layoutAttributes
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let superLayoutAttributes = super.layoutAttributesForElements(in: rect) else {
            return nil
        }
        let computedAttributes = superLayoutAttributes.compactMap { layoutAttribute in
            return layoutAttribute.representedElementCategory == .cell ? layoutAttributesForItem(at: layoutAttribute.indexPath) : layoutAttribute
        }
        return computedAttributes
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }

}
