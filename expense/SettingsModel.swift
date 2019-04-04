//
//  SettingsModel.swift
//  InVoice
//
//  Created by Georg Kitz on 20/12/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import Foundation
import CoreData
import Horreum
import RxSwift

class SettingsModel: TableModel {
    
    private let storeService: StoreService
    
    func restorePurchase() -> Observable<Void> {
        return storeService.restorePurchase()
    }
    
    init(storeService: StoreService = StoreService.instance) {
        
        self.storeService = storeService
        
        super.init(with: Horreum.instance!.mainContext)
        
        let businessSection = BusinessSection()
        let infoSection = InfoSection()
        
        let accountObs = Account.rxAllObjects(context: context).map { $0.first }.filterNil().distinctUntilChanged { (oldAccount, newAccount) -> Bool in
            return oldAccount.name != newAccount.name
        }.mapToVoid()
            
        let storeObs = self.storeService.hasValidReceiptObservable.distinctUntilChanged().mapToVoid()
        
        Observable.of(accountObs, storeObs).merge().subscribe(onNext: { [unowned self] (_) in
            var sections = [UserSection(with: self.context), businessSection, ProSection(storeService: storeService), infoSection]
            #if DEBUG
                sections.append(DebugSection())
            #endif
            self.sections = sections
            
        }).disposed(by: bag)
        
    }
    
    required init(with context: NSManagedObjectContext) {
        fatalError("init(with:) has not been implemented")
    }
}
