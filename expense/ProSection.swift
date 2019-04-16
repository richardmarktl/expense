//
//  ProSection.swift
//  InVoice
//
//  Created by Georg Kitz on 20/12/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import UIKit

class ProSection: Section {
    init(storeService: StoreService) {
        
        let shouldShowProBadge = !storeService.hasValidReceipt
        let isPro = CurrentAccountState.isPro
        
        let row1 = SettingsItem(image: R.image.settings_backup()!, title: R.string.localizable.backup(), isProFeature: shouldShowProBadge, allowToAccessProFeature: isPro)
        let action1 = BackupAction()
        let row2 = SettingsItem(image: R.image.settings_read_receipt()!, title: R.string.localizable.emailReadReceipts(), isProFeature: shouldShowProBadge, allowToAccessProFeature: isPro)
        let action2 = ReadReceiptAction()
        let row3 = SettingsItem(image: R.image.settings_color_scheme()!, title: R.string.localizable.personalizeHeader(), isProFeature: shouldShowProBadge, allowToAccessProFeature: isPro, accessibilityIdentifier: "theme_settings")
        let action3 = ThemeAction()
        let row4 = SettingsItem(image: R.image.settings_payment_provider()!, title: R.string.localizable.paymentSection(), isProFeature: shouldShowProBadge, allowToAccessProFeature: isPro)
        let action4 = SettingsPaymentProviderAction()
        
        let row5 = SettingsItem(image: R.image.settings_payment_provider()!, title: R.string.localizable.signatureSection(), isProFeature:
            shouldShowProBadge, allowToAccessProFeature: isPro)
        let action5 = SignatureAction()
        
        let rows: [ConfigurableRow] = [
            TableRow<SettingsCell, BackupAction>(item: row1, action: action1),
            TableRow<SettingsCell, ReadReceiptAction>(item: row2, action: action2),
            TableRow<SettingsCell, ThemeAction>(item: row3, action: action3),
            TableRow<SettingsCell, SettingsPaymentProviderAction>(item: row4, action: action4),
            TableRow<SettingsCell, SignatureAction>(item: row5, action:action5)
        ]
        
        super.init(rows: rows, headerTitle: R.string.localizable.pro())
    }
}
