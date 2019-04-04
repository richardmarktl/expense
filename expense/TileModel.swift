//
//  TileModel.swift
//  InVoice
//
//  Created by Georg Kitz on 11/01/2018.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import RxSwift

struct TileItem {
    let description: String
    let title: String
    let isPro: Bool
    let showProBadge: Bool
}

class TileAction {
    func performTap(with rowItem: TileItem, indexPath: IndexPath, collectionView: UICollectionView, ctr: UIViewController, model: TileModel) {}
}

class ShowOutstandingAction: TileAction {
    override func performTap(with rowItem: TileItem, indexPath: IndexPath, collectionView: UICollectionView, ctr: UIViewController, model: TileModel) {
        let pCtr = UnpaidInvoicesController()
        Analytics.reportOustanding.logEvent()
        ctr.navigationController?.pushViewController(pCtr, animated: true)
    }
}

class ShowOverdueInvoices: TileAction {
    override func performTap(with rowItem: TileItem, indexPath: IndexPath, collectionView: UICollectionView, ctr: UIViewController, model: TileModel) {
        if !rowItem.isPro {
            Analytics.reportOverduePro.logEvent()
            UpsellTrialExpiredController.present(in: ctr)
            return
        }
        let pCtr = OverdueInvoicesController()
        Analytics.reportOverdue.logEvent()
        ctr.navigationController?.pushViewController(pCtr, animated: true)
    }
}

class ShowOverdueInvoicesTomorrow: TileAction {
    override func performTap(with rowItem: TileItem, indexPath: IndexPath, collectionView: UICollectionView, ctr: UIViewController, model: TileModel) {
        if !rowItem.isPro {
            Analytics.reportOverdueTomorrowPro.logEvent()
            UpsellTrialExpiredController.present(in: ctr)
            return
        }
        let pCtr = OverdueTomorrowInvoicesController()
        Analytics.reportOverdueTomorrow.logEvent()
        ctr.navigationController?.pushViewController(pCtr, animated: true)
    }
}

class ShowUnsentAction: TileAction {
    override func performTap(with rowItem: TileItem, indexPath: IndexPath, collectionView: UICollectionView, ctr: UIViewController, model: TileModel) {
        let pCtr = UnsentInvoicesController()
        Analytics.reportUnsent.logEvent()
        ctr.navigationController?.pushViewController(pCtr, animated: true)
    }
}

class ShowUnseenAction: TileAction {
    override func performTap(with rowItem: TileItem, indexPath: IndexPath, collectionView: UICollectionView, ctr: UIViewController, model: TileModel) {
        if !rowItem.isPro {
            Analytics.reportUnseenPro.logEvent()
            UpsellTrialExpiredController.present(in: ctr)
            return
        }
        
        let pCtr = UnseenInvoicesController()
        Analytics.reportUnseen.logEvent()
        ctr.navigationController?.pushViewController(pCtr, animated: true)
    }
}

class ShowBackupAction: TileAction {
    override func performTap(with rowItem: TileItem, indexPath: IndexPath, collectionView: UICollectionView, ctr: UIViewController, model: TileModel) {
        if !rowItem.isPro {
            Analytics.reportBackupPro.logEvent()
            UpsellTrialExpiredController.present(in: ctr)
            return
        }
        
        Analytics.reportBackup.logEvent()
    }
}

extension Int {
    func toStringWithLeadingZero() -> String {
        return String(format: "%01d", self)
    }
}

class TileModel {

    private let bag = DisposeBag()
    private let itemSubject: Variable<[TileItem]> = Variable([])
    var itemObservable: Observable<[TileItem]> {
        return itemSubject.asObservable()
    }
    var items: [TileItem] {
        return itemSubject.value
    }
    
    private let context: NSManagedObjectContext
    private let actions: [TileAction] = [
        ShowOutstandingAction(),
        ShowUnsentAction(),
        ShowUnseenAction(),
        ShowOverdueInvoices(),
        ShowOverdueInvoicesTomorrow(),
        ShowBackupAction()
    ]
    
    required init(with context: NSManagedObjectContext) {
        
        let unpaidObs = Invoice.rxAllObjects(matchingPredicate: NSPredicate.unpaidInvoices(), context: context).map { (items) -> TileItem in
            return TileItem(description: R.string.localizable.outstandingInvoices(), title: items.count.toStringWithLeadingZero(),
                            isPro: false, showProBadge: false)
        }
        
        let unsentObs = Invoice.rxAllObjects(matchingPredicate: NSPredicate.unsentInvoices(), context: context).map { (items) -> TileItem in
            return TileItem(description: R.string.localizable.unsentInvoices(), title: items.count.toStringWithLeadingZero(),
                            isPro: false, showProBadge: false)
        }
        
        let unseenObs = Invoice.rxAllObjects(matchingPredicate: NSPredicate.unopenedInvoices(), context: context).map { (items) -> TileItem in
            let isPro = CurrentAccountState.isPro
            let showProBadge = !StoreService.instance.hasValidReceipt
            return TileItem(description: R.string.localizable.unseenInvoices(), title: items.count.toStringWithLeadingZero(),
                            isPro: isPro, showProBadge: showProBadge)
        }
        
        let overdueObs = Invoice.rxAllObjects(matchingPredicate: NSPredicate.overdueInvoices(), context: context).map { (items) -> TileItem in
            let isPro = CurrentAccountState.isPro
            let showProBadge = !StoreService.instance.hasValidReceipt
            return TileItem(description: R.string.localizable.overdueInvoices(), title: items.count.toStringWithLeadingZero(),
                            isPro: isPro, showProBadge: showProBadge)
        }
        
        let overdueTomrorrowObs = Invoice.rxAllObjects(matchingPredicate: NSPredicate.overdueTomorrowInvoices(), context: context).map { (items) -> TileItem in
            let isPro = CurrentAccountState.isPro
            let showProBadge = !StoreService.instance.hasValidReceipt
            return TileItem(description: R.string.localizable.overdueTomorrowInvoices(), title: items.count.toStringWithLeadingZero(),
                            isPro: isPro, showProBadge: showProBadge)
        }
        
        let latestObs = UserDefaults.lastUpdateDaysAgoObservable.map { (daysAgo) -> TileItem in
            let isPro = !StoreService.instance.hasValidReceipt
            return TileItem(description: R.string.localizable.lastBackup(), title: daysAgo.toStringWithLeadingZero(),
                            isPro: isPro, showProBadge: isPro)
        }
        
        Observable.combineLatest([
            unpaidObs,
            unsentObs,
            unseenObs,
            overdueObs,
            overdueTomrorrowObs,
            latestObs
        ]).bind(to: itemSubject).disposed(by: bag)
        
        self.context = context
    }
    
    func performTap(at indexPath: IndexPath, for collectionView: UICollectionView, in ctr: UIViewController) {
        actions[indexPath.row].performTap(with: items[indexPath.row], indexPath: indexPath, collectionView: collectionView, ctr: ctr, model: self)
    }
}
