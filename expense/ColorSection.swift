//
//  ColorSection.swift
//  InVoice
//
//  Created by Georg Kitz on 27.03.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import UIKit

/// ColorItem
class ColorItem: BasicItem<UIColor> {
    init(design: JobDesign) {
        
        let defaultColor: UIColor
        if let colorString = design.color {
            defaultColor = UIColor(hexString: colorString)
        } else {
            defaultColor = UIColor.main
        }
        super.init(title: R.string.localizable.chooseColor(), defaultData: defaultColor)
    }
}

/// ColorAction
class ColorAction: TapActionable {
    typealias RowActionType = ColorItem
    func performTap(with rowItem: ColorItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: TableModel) {
        
        Analytics.themeColor.logEvent()
        
        guard let colorCtr = R.storyboard.settings.colorPickerController() else {
            return
        }
        
        colorCtr.colorItem = rowItem
        ctr.navigationController?.pushViewController(colorCtr, animated: true)
    }
    
    func rewindAction(with rowItem: ColorItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: TableModel) {
        
    }
}
