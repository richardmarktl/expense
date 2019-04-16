//
//  AccountBaseModel.swift
//  InVoice
//
//  Created by Georg Kitz on 24/01/2018.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class AccountBaseModel: Model {
    var name: String
    var validUntil: String
    
    var nameEntry: TextEntry
    var emailEntry: TextEntry
    
    let account: Account
    
    required init(with context: NSManagedObjectContext, sectionTitle: String) {
        
        account = Account.current(context: context)
        if let companyName = account.name, companyName.count != 0 {
            name = R.string.localizable.hey(companyName)
        } else {
            name = R.string.localizable.hey(R.string.localizable.ya())
        }
        
        switch CurrentAccountState.value {
        case .freeTrail:
            let expireDateString = CurrentAccountState.freeAccountExpireDate.asString(.medium, timeStyle: .none)
            validUntil = R.string.localizable.accountFreeTrailInfo(expireDateString)
        case .trialExpired:
            let expireDateString = CurrentAccountState.freeAccountExpireDate.asString(.medium, timeStyle: .none)
            validUntil = R.string.localizable.accountFreeTrailExpired(expireDateString)
        default:
            let dateString = (StoreService.expirationDate() ?? Date()).asString(.medium, timeStyle: .none)
            validUntil = R.string.localizable.accountValidUntil(dateString)
        }
        
        nameEntry = TextEntry(placeholder: R.string.localizable.name(), value: account.name, keyboardType: .namePhonePad,
                              textContentType: .name, autoCapitalizationType: UITextAutocapitalizationType.words)
        emailEntry = TextEntry(placeholder: R.string.localizable.email(), value: account.email, keyboardType: .emailAddress, textContentType: .emailAddress)
        
        super.init(with: context)
        
        let rows: [ConfigurableRow] = [
            TableRow<TextFieldCell, FirstResponderActionTextFieldCell>(item: nameEntry, action: FirstResponderActionTextFieldCell()),
            TableRow<TextFieldCell, FirstResponderActionTextFieldCell>(item: emailEntry, action: FirstResponderActionTextFieldCell())
        ]
        sections = [Section(rows: rows, footerTitle: sectionTitle)]
    }
    
    required init(with context: NSManagedObjectContext) {
        fatalError("init(with:) has not been implemented")
    }
}
