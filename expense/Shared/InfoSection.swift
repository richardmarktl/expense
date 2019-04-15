//
//  InfoSection.swift
//  InVoice
//
//  Created by Georg Kitz on 20/12/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import UIKit

class InfoSection: TableSection<UITableView> {
    init() {
        
        let row1 = SettingsItem(image: R.image.settings_email_support()!, title: R.string.localizable.emailSupport(), isProFeature: false, allowToAccessProFeature: false)
        let action1 = EmailSupportAction()
        let row2 = SettingsItem(image: R.image.settings_share_app()!, title: R.string.localizable.shareApp(), isProFeature: false, allowToAccessProFeature: false)
        let action2 = ShareAction()
        let row3 = SettingsItem(image: R.image.settings_rate_app()!, title: R.string.localizable.rateApp(), isProFeature: false, allowToAccessProFeature: false)
        let action3 = RateAction()
        let row4 = SettingsItem(image: R.image.settings_terms()!, title: R.string.localizable.termsAPrivacy(), isProFeature: false, allowToAccessProFeature: false)
        let action4 = TermsAndPrivacyAction()
        let row5 = SettingsItem(image: R.image.settings_newsletter()!, title: R.string.localizable.subscribeToNewsletter(), isProFeature: false, allowToAccessProFeature: false)
        let action5 = NewsletterAction()
        
        let rows: [Row<UITableView>] = [
            TableRow<SettingsCell, EmailSupportAction>(item: row1, action: action1),
            TableRow<SettingsCell, ShareAction>(item: row2, action: action2),
            TableRow<SettingsCell, RateAction>(item: row3, action: action3),
            TableRow<SettingsCell, TermsAndPrivacyAction>(item: row4, action: action4),
            TableRow<SettingsCell, NewsletterAction>(item: row5, action: action5)
        ]
        
        super.init(rows: rows, headerTitle: R.string.localizable.info())
    }
}
