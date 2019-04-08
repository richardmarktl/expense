//
//  TableFooterView.swift
//  InVoice
//
//  Created by Georg Kitz on 20.02.19.
//  Copyright © 2019 meisterwork GmbH. All rights reserved.
//

import UIKit

class FooterLabel: UILabel {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // this is totally random, if we don't set a custom font before we set
        // the attributed string, the attributed string will be shown with the font
        // setup in the storyboard, for fuck sake, 2 days wasted!!!
        font = UIFont.systemFont(ofSize: 23)
    }
}

class TableFooterView: UITableViewHeaderFooterView {
    @IBOutlet weak var footerLabel: FooterLabel?
}
