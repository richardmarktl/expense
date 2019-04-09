//
//  WalletViewController.swift
//  expense
//
//  Created by Richard Marktl on 04.04.19.
//  Copyright © 2019 meisterwork GmbH. All rights reserved.
//

import Foundation
import UIKit

class WalletViewController: UICollectionViewController {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1;
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5;
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.walletCell, for: indexPath)
        // cell.backgroundColor = .black
        // Configure the cell
        print("hallo du");
        return cell!
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let nCtr = NewWalletViewController.createWallet()
        // Analytics.itemNew.logEvent()
        self.present(nCtr, animated: true)
    }
}
