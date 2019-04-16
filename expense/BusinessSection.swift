//
//  BusinessSection.swift
//  InVoice
//
//  Created by Georg Kitz on 20/12/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import Foundation
import UIKit
import CommonUI

class BusinessSection: Section<UITableView> {
    init() {
        let rows: [Row<UITableView>] = [];
//        let row1 = SettingsItem(image: R.image.settings_business_details()!, title: R.string.localizable.businessDetails(), isProFeature: false, allowToAccessProFeature: false)
//        let action1 = SettingsBusinessDetailsAction()
//        let row3 = SettingsItem(image: R.image.settings_taxes()!, title: R.string.localizable.taxes(), isProFeature: false, allowToAccessProFeature: false)
//        let action3 = SettingsTaxAction()
//        let row2 = SettingsItem(image: R.image.settings_default_note()!, title: R.string.localizable.businessSettings(), isProFeature: false, allowToAccessProFeature: false)
//        let action2 = SettingsBusinessSettingsAction()
//
//        let rows: [Row<UITableView>] = [
//            TableRow<SettingsCell, SettingsBusinessDetailsAction>(item: row1, action: action1),
//            TableRow<SettingsCell, SettingsBusinessSettingsAction>(item: row2, action: action2),
//            TableRow<SettingsCell, SettingsTaxAction>(item: row3, action: action3)
//        ]
        
        super.init(rows: rows)
    }
}
