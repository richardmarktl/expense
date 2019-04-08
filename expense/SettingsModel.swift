//
//  SettingsModel.swift
//  InVoice
//
//  Created by Georg Kitz on 20/12/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import Foundation
import CoreData
import RxSwift

class SettingsModel: TableModel {
    private let storeService: StoreService
    
    func restorePurchase() -> Observable<Void> {
        return storeService.restorePurchase()
    }
    
    required init(with context: NSManagedObjectContext) {
        self.storeService = StoreService.instance;
        
        super.init(with: context)
        
        let businessSection = BusinessSection()
        let infoSection = InfoSection()
        
//        let accountObs = Account.rxAllObjects(context: context).map { $0.first }.filterNil().distinctUntilChanged { (oldAccount, newAccount) -> Bool in
//            return oldAccount.name != newAccount.name
//        }.mapToVoid()
//
//        let storeObs = self.storeService.hasValidReceiptObservable.distinctUntilChanged().mapToVoid()
//
//        Observable.of(accountObs, storeObs).merge().subscribe(onNext: { [unowned self] (_) in
//            var sections = [UserSection(with: self.context), businessSection, ProSection(storeService: storeService), infoSection]
//            #if DEBUG
//                sections.append(DebugSection())
//            #endif
//            self.sections = sections
//
//        }).disposed(by: bag)

        self.storeService.hasValidReceiptObservable.distinctUntilChanged().mapToVoid().subscribe(onNext: { [unowned self] (_) in
            self.sections = [UserSection(with: self.context), businessSection, infoSection]
            
        }).disposed(by: bag)
    }
}
