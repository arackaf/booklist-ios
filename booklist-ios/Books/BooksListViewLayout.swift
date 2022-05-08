//
//  BooksListViewLayout.swift
//  booklist-ios
//
//  Created by Adam Rackis on 5/8/22.
//

import UIKit

class BooksListViewLayout: UICollectionViewFlowLayout {
    override func prepare() {
        super.prepare()

        guard let collectionView = collectionView else { return }
        
        let availableWidth = collectionView.bounds.inset(by: collectionView.layoutMargins).width
        //let maxNumColumns = Int(availableWidth / minColumnWidth)
        //let cellWidth = (availableWidth / CGFloat(maxNumColumns)).rounded(.down)
        
        //self.itemSize = CGSize(width: cellWidth, height: cellHeight)
        //self.sectionInset = UIEdgeInsets(top: self.minimumInteritemSpacing, left: 0.0, bottom: 0.0, right: 0.0)
        //self.sectionInsetReference = .fromSafeArea
    }
}
