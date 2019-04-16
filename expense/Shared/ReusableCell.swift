//
//  ReusableCell.swift
//  InVoice
//
//  Created by Georg Kitz on 14/11/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import UIKit
import RxSwift

class ReusableTableViewCell: UITableViewCell {
    
    private(set)var reusableBag: DisposeBag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        reusableBag = DisposeBag()
    }
}

class ReusableCollectionViewCell: UICollectionViewCell {
    
    private(set)var reusableBag: DisposeBag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        reusableBag = DisposeBag()
    }
}
