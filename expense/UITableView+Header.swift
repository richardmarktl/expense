//
//  UITableView+Header.swift
//  InVoice
//
//  Created by Georg Kitz on 16.08.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import UIKit

extension UITableView {
    // set the tableHeaderView so that the required height can be determined, update the header's frame and set it again
    // https://stackoverflow.com/questions/28079591/using-autolayout-in-a-tableheaderview
    func setAndLayoutTableHeaderView(header: UIView) {
        tableHeaderView = header
        header.setNeedsLayout()
        header.layoutIfNeeded()
        
        let height = header.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
        
        var frame = header.frame
        frame.size.height = height
        header.frame = frame
        
        tableHeaderView = header
    }
}
