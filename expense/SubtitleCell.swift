//
//  SubtitleCell.swift
//  InVoice
//
//  Created by Georg Kitz on 28.09.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import UIKit

class SubtitleCell: ReusableCell, ConfigurableCell {
    typealias ConfigType = SubtitleItem
    func configure(with item: SubtitleItem) {
        textLabel?.text = item.title
        detailTextLabel?.text = item.subtitle
    }
}
