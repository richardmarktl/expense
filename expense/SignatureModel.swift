//
//  SignatureModel.swift
//  InVoice
//
//  Created by Richard Marktl on 04.09.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation
import CoreData
import Horreum
import RxSwift
import SwiftMoment

class SignatureModel: DetailModel<Account> {
    let signatureSection: SignatureSettingSection
    
    required init(item: Account, storeChangesAutomatically: Bool, deleteAutomatically: Bool, sections: [TableSection], in context: NSManagedObjectContext) {
        
        signatureSection = SignatureSettingSection(item: item)
        
        super.init(item: item, storeChangesAutomatically: true, deleteAutomatically: true, sections: [signatureSection], in: context)
    }
    
    required init(with context: NSManagedObjectContext) {
        fatalError("init(with:) has not been implemented")
    }
}
