//
//  InvoiceGeneratorItems.swift
//  InVoice
//
//  Created by Georg Kitz on 06/12/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import Foundation
import UIKit

protocol Pdfable {
    func pdfData(in locale: Locale) -> [String: Any]
}

// MARK: - Parent to PDF
extension Job {
    // swiftlint:disable function_body_length
    func pdfData() -> [String: Any] {
        
        let jobLocalization = JobLocalization.localization(for: language, in: managedObjectContext!)
        
        var values: [String: Any] = [:]
        
        values["type"] = localizedTypeKey.localizedUserValue(for: jobLocalization)
        values["externalIdTitle"] = localizedTypeNumberKey.localizedUserValue(for: jobLocalization)
        values["externalId"] = number as Any
        values["customerName"] = clientName as Any
        values["customerId"] = clientNumber as Any
        values["dateTitle"] = R.string.localizable.dateTitle.key.localizedUserValue(for: jobLocalization)
        values["date"] = date?.asString(.medium, timeStyle: .none) as Any
        values["customerTaxId"] = clientTaxId as Any
        values["customerAddress"] = clientAddress as Any
        values["orders"] = ordersTyped
            .asSorted()
            .map { $0.pdfData(with: jobLocalization) }
        values["hasOrders"] = ordersTyped.count > 0
        
        let balance = BalanceModel.balance(for: self)
        values["subtotalTitle"] = R.string.localizable.subtotalTitle.key.localizedUserValue(for: jobLocalization)
        values["subtotal"] = balance.subtotal
        
        if let discount = discount, discount != NSDecimalNumber.zero {
            if !isDiscountAbsolute {
                values["discountTitle"] = R.string.localizable.discountTitle.key.localizedUserValue(for: jobLocalization) + " " + discount.asString() + "%"
            } else {
                values["discountTitle"] = R.string.localizable.discountTitle.key.localizedUserValue(for: jobLocalization)
            }
            values["discount"] = balance.discount
        }
        
        values["vat"] = balance.vat
        values["balanceTitle"] = R.string.localizable.balanceTitle.key.localizedUserValue(for: jobLocalization)
        values["balance"] = balance.balance
        
        values["headerArticleNumber"] = R.string.localizable.headerArticleNumber.key.localizedUserValue(for: jobLocalization)
        values["headerArticle"] = R.string.localizable.headerArticle.key.localizedUserValue(for: jobLocalization)
        values["headerDescription"] = R.string.localizable.headerDescription.key.localizedUserValue(for: jobLocalization)
        values["headerPrice"] = R.string.localizable.headerPrice.key.localizedUserValue(for: jobLocalization)
        values["headerQuantity"] = R.string.localizable.headerQuantity.key.localizedUserValue(for: jobLocalization)
        values["headerTotal"] = R.string.localizable.headerTotal.key.localizedUserValue(for: jobLocalization)
        
        values["vats"] = balance.vats.vatToTax.map({ (item) -> [String: String] in
            var vat: [String: String] = [:]
            vat["title"] = R.string.localizable.vatsTitle.key.localizedUserValue(for: jobLocalization) + " " + item.key + "%"
            vat["amount"] = item.value.asCurrency(currencyCode: currency)
            return vat
        })
        
        values["note"] = note as Any
        values["paymentDetailsTitle"] = R.string.localizable.paymentDetailsTitle.key.localizedUserValue(for: jobLocalization)
        values["paymentDetails"] = paymentDetails as Any
                
        if let invoice = self as? Invoice {
            values["dueDateTitle"] = R.string.localizable.dueDateTitle.key.localizedUserValue(for: jobLocalization)
            values["dueDate"] = invoice.dueTimestamp?.asString(.medium, timeStyle: .none) as Any
            if invoice.paymentsTyped.count > 0 {
                values["paidTitle"] = R.string.localizable.paidTitle.key.localizedUserValue(for: jobLocalization)
                values["paid"] = balance.paid
            }
        }
        
        values["signatureName"] = signatureName as Any
        
        return values
    }
    // swiftlint:enable function_body_length
}

// MARK: - Order to PDF
extension Order {
    func pdfData(with jobLocalization: JobLocalization?) -> [String: Any] {
        let currencyCode = item?.currency
        var values: [String: Any] = [:]
        values["name"] = title as Any
        values["description"] = itemDescription as Any
        values["price"] = price?.asCurrency(currencyCode: currencyCode) as Any
        values["quantity"] = quantity?.asString() as Any
        values["total"] = total?.asCurrency(currencyCode: currencyCode) as Any
        values["number"] = number as Any
        if let discount = discount, discount != NSDecimalNumber.zero {
            if isDiscountAbsolute {
                values["orderDiscount"] = R.string.localizable.discountTitle.key.localizedUserValue(for: jobLocalization) + " " + discount.asCurrency(currencyCode: currencyCode)
            } else {
                values["orderDiscount"] = R.string.localizable.discountTitle.key.localizedUserValue(for: jobLocalization) + " " + discount.asString() + "%"
            }
        }
        return values
    }
}

// MARK: - Attachment to PDF
extension Attachment {
    func pdfData() -> [String: Any] {
        var values: [String: Any] = [:]
        
        guard let internalFilename = uuid, let image = ImageStorage.loadAlreadyLoadedItem(for: internalFilename) else {
            return [:]
        }

        values["data"] = ImageStorage.base64String(for: image.image, type: .jpg(quality: 0.5)) as Any
        values["description"] = fileName as Any
        return values
    }
}
