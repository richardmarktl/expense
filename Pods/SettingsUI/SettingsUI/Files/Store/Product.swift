//
// Created by Richard Marktl on 2019-05-16.
// Copyright (c) 2019 meisterwork. All rights reserved.
//

import Foundation
import StoreKit

struct Purchase {
    let product: Product
    let success: Bool
}

private var formatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.formatterBehavior = .behavior10_4

    return formatter
}()

private func format(price: NSDecimalNumber, period: Int = 1) -> String {
    if period == 1 {
        return formatter.string(from: price) ?? "\(price)"
    }
    return formatter.string(from: price.dividing(by: NSDecimalNumber(value: period))) ?? "\(price)"
}

public struct Product {
    let product: SKProduct
    let periodPrice: String
    let monthlyPrice: String
    let isMonthBasedPeriod: Bool
    let hasTrail: Bool
    let currencyString: String
    let period: Int // basically months

    var trackingTitle: String {
        if isMonthBasedPeriod {
            return "monthly"
        }
        return "yearly"
    }

    init(with product: SKProduct, period: Int = 1, hasTrail: Bool = true) {
        self.product = product
        self.period = period
        self.hasTrail = hasTrail

        if formatter.locale != self.product.priceLocale {
            formatter.locale = self.product.priceLocale
        }

        let price = product.price
        currencyString = product.priceLocale.currencyCode ?? "USD"
        periodPrice = format(price: price)
        monthlyPrice = format(price: price, period: period)
        isMonthBasedPeriod = (period > 12)
    }
}
