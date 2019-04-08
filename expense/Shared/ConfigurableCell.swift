//
//  ConfigurableCell.swift
//  InVoice
//
//  Created by Georg Kitz on 15/11/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import UIKit

protocol ConfigurableCell {
    associatedtype ConfigType
    static var reuseIdentifier: String {get}
    func configure(with item: ConfigType)
}

extension ConfigurableCell where Self: UITableViewCell {
    
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

extension ConfigurableCell where Self: UICollectionViewCell {
    
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}
