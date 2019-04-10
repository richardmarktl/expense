//
// Created by Richard Marktl on 2019-04-10.
// Copyright (c) 2019 meisterwork GmbH. All rights reserved.
//

import Foundation

class WalletItem: BasicItem<Wallet> {

    private(set) var name: String = ""
    private(set) var type: String = ""

    init(defaultData: Wallet) {
        super.init(defaultData: defaultData)
        update(with: defaultData)
    }

    func update(with wallet: Wallet) {
        name = wallet.name ?? ""
        type = wallet.localizedWalletType
        data.value = wallet
    }
}