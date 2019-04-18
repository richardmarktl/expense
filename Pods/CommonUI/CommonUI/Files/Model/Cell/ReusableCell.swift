//
//  ReusableCell.swift
//  InVoice
//
//  Created by Georg Kitz on 14/11/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import UIKit
import RxSwift

open class ReusableTableViewCell: UITableViewCell {

    private(set) public var reusableBag: DisposeBag = DisposeBag()

    open override func prepareForReuse() {
        super.prepareForReuse()
        reusableBag = DisposeBag()
    }
}


open class ReusableCollectionViewCell: UICollectionViewCell {

    private(set) public var reusableBag: DisposeBag = DisposeBag()

    open override func prepareForReuse() {
        super.prepareForReuse()
        reusableBag = DisposeBag()
    }
}
