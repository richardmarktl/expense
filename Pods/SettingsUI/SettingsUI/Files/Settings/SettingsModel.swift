//
//  SettingsModel.swift
//  SettingsUI
//
// Created by Richard Marktl on 2019-05-09.
// Copyright (c) 2019 meisterwork. All rights reserved.
//

import Foundation
import CoreData
import RxSwift
import CommonUI


open class SettingsModel: Model<UITableView> {
    public let infoSection: InfoSection
    public let userSection: UserSection

    public required init(with context: NSManagedObjectContext) {
        infoSection = InfoSection()
        userSection = UserSection(userItem: nil)

        super.init(with: context)

        sections = [userSection, infoSection]
    }
}
