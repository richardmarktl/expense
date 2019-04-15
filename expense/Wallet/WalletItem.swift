//
// Created by Richard Marktl on 2019-04-10.
// Copyright (c) 2019 meisterwork GmbH. All rights reserved.
//

import Foundation
import InvoiceBotSDK

class WalletItem: BasicItem<BudgetWallet> {

    private(set) var name: String = ""
    private(set) var type: String = ""

    init(defaultData: BudgetWallet) {
        super.init(defaultData: defaultData)
        update(with: defaultData)
    }

    func update(with wallet: BudgetWallet) {
        name = wallet.name ?? ""
        type = wallet.localizedWalletType
        data.value = wallet
    }
}
