//
// Created by Richard Marktl on 2019-04-18.
// Copyright (c) 2019 meisterwork GmbH. All rights reserved.
//

import Foundation
import InvoiceBotSDK

class BudgetEntryItem: BasicItem<BudgetEntry> {

    private(set) var name: String = ""
    private(set) var type: String = ""

    init(defaultData: BudgetEntry) {
        super.init(defaultData: defaultData)
        update(with: defaultData)
    }

    func update(with entry: BudgetEntry) {
//        name = entry.name ?? ""
//        type = entry.localizedWalletType
        data.value = entry
    }
}
