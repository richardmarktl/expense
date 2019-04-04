//
//  DebugSection.swift
//  InVoice
//
//  Created by Georg Kitz on 02.05.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation
import RxSwift
import SwiftMoment

class DebugSection: TableSection {
    let isProAccount: BoolItem
    private let bag = DisposeBag()
    init() {
        
        isProAccount = BoolItem(title: "Is Pro Account", defaultData: StoreService.instance.hasValidReceipt)
        let account = Account.current()
        
        let rows: [ConfigurableRow] = [
                TableRow<SwitchCell, NoOperationBoolAction>(item: isProAccount, action: NoOperationBoolAction()),
                TableRow<SubtitleCell, UpdateExpireDateTo2MinutesFromNowAction>(item: SubtitleItem(account: account), action: UpdateExpireDateTo2MinutesFromNowAction()),
                TableRow<SubtitleCell, ResetFuckUpStateAction>(item: SubtitleItem(title: "Reset Fuck Up", subtitle: "Tapping it will close the app and reupload on next start"), action: ResetFuckUpStateAction())
            ]
        super.init(rows: rows, headerTitle: "Debug")
        
        isProAccount.data.asObservable().subscribe(onNext: { value in
            StoreService.instance.overrideValiditidy(to: value)
        }).disposed(by: bag)
    }
    
    fileprivate func updateExpireTime2ToMinutesFromNow() {
        
        let date = moment().add(2, TimeUnit.Minutes)
        let account = Account.current()
        account.trailEndedTimestamp = date.date
        try? account.managedObjectContext?.save()
        
        rows.remove(at: 1)
        
        let row = TableRow<SubtitleCell, UpdateExpireDateTo2MinutesFromNowAction>(item: SubtitleItem(account: account), action: UpdateExpireDateTo2MinutesFromNowAction())
        rows.insert(row, at: 1)
    }
}

fileprivate extension SubtitleItem {
    init(account: Account) {
        let date = account.trailEndedTimestamp ?? Date()
        self.init(title: "Set Trial End 2min from now", subtitle: "Ends: " + date.asString(.short, timeStyle: .medium))
    }
}

fileprivate class UpdateExpireDateTo2MinutesFromNowAction: TapActionable {
    typealias RowActionType = SubtitleItem
    func performTap(with rowItem: SubtitleItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model:
        TableModel) {
        defer { tableView.deselectRow(at: indexPath, animated: true) }
        
        guard let section = model.sections.last as? DebugSection else { return }
        section.updateExpireTime2ToMinutesFromNow()
    }
    
    func rewindAction(with rowItem: SubtitleItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: TableModel) {
    }
}

fileprivate class ResetFuckUpStateAction: TapActionable {
    typealias RowActionType = SubtitleItem
    func performTap(with rowItem: SubtitleItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model:
        TableModel) {
        defer { tableView.deselectRow(at: indexPath, animated: true) }
        
        UserDefaults.standard.set(false, forKey: "did_run_fuck_up_resolver")
        UserDefaults.standard.synchronize()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            exit(1)
        }
    }
    
    func rewindAction(with rowItem: SubtitleItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: TableModel) {
    }
}
