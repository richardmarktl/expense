//
//  InfoSection.swift
//  SettingsUI
//
// Created by Richard Marktl on 2019-05-09.
// Copyright (c) 2019 meisterwork. All rights reserved.
//

import UIKit
import CommonUtil
import CommonUI

open class InfoSection: Section<UITableView> {
    init() {
        let row1 = SettingsItem(imageName: "settings_email_support", title: PodLocalizedString("emailSupport", comment: ""))
        let action1 = EmailSupportAction()
        let row2 = SettingsItem(imageName: "settings_share_app", title: PodLocalizedString("shareApp", comment: ""))
        let action2 = ShareAction()
        let row3 = SettingsItem(imageName: "settings_rate_app", title: PodLocalizedString("rateApp", comment: ""))
        let action3 = RateAction()
        let row4 = SettingsItem(imageName: "settings_terms", title: PodLocalizedString("termsAPrivacy", comment: ""))
        let action4 = TermsAndPrivacyAction()
        let row5 = SettingsItem(imageName: "settings_newsletter", title: PodLocalizedString("subscribeToNewsletter", comment: ""))
        let action5 = NewsletterAction()

        let rows: [Row<UITableView>] = [
            TableRow<SettingsCell, EmailSupportAction>(item: row1, action: action1),
            TableRow<SettingsCell, ShareAction>(item: row2, action: action2),
            TableRow<SettingsCell, RateAction>(item: row3, action: action3),
            TableRow<SettingsCell, TermsAndPrivacyAction>(item: row4, action: action4),
            TableRow<SettingsCell, NewsletterAction>(item: row5, action: action5)
        ]

        super.init(rows: rows, headerTitle:PodLocalizedString("info", comment: ""))
    }
}
