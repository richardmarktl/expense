//
//  ReusableCell.swift
//  InVoice
//
//  Created by Georg Kitz on 14/11/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import UIKit
import RxSwift

public class ReusableTableViewCell: UITableViewCell {

    private(set) public var reusableBag: DisposeBag = DisposeBag()

    public override func prepareForReuse() {
        super.prepareForReuse()
        reusableBag = DisposeBag()
    }
}


public class ReusableCollectionViewCell: UICollectionViewCell {

    private(set) public var reusableBag: DisposeBag = DisposeBag()

    public override func prepareForReuse() {
        super.prepareForReuse()
        reusableBag = DisposeBag()
    }
}
