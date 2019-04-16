//
//  BackupModel.swift
//  InVoice
//
//  Created by Georg Kitz on 24/01/2018.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import RxSwift
import SwiftMoment

class RestoreBackupAction: TapActionable {
    typealias RowActionType = ProgressItem
    
    func performTap(with rowItem: ProgressItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: Model) {
        Analytics.backupRestore.logEvent()
        if rowItem.isInProgress {
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        
        rowItem.isInProgress = true
        tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
        
        _ = Downloader.instance!.restoreFromBackup().takeLast(1).subscribe(onNext: { [weak rowItem, weak tableView]_ in
            
            rowItem?.isInProgress = false
            tableView?.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
        })
    }
    
    func rewindAction(with rowItem: ProgressItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: Model) {
        
    }
}

class ExportCSVAction: TapActionable {
    typealias RowActionType = ProgressItem
    
    func performTap(with rowItem: ProgressItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: Model) {
        Analytics.backupExport.logEvent()
        if rowItem.isInProgress {
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        
        rowItem.isInProgress = true
        tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
        
        guard let model = model as? BackupModel, let ctr = ctr as? BackupViewController else {
            return
        }
        
        model.exportAsCSV().subscribe(onNext: { (filePath) in
            
            let activityCtr = UIActivityViewController(activityItems: [filePath], applicationActivities: nil)
            if UIDevice.current.userInterfaceIdiom == .pad {
                activityCtr.popoverPresentationController?.sourceView = tableView.cellForRow(at: indexPath)
                activityCtr.popoverPresentationController?.sourceRect = tableView.cellForRow(at: indexPath)?.bounds ?? CGRect.zero
            }
            ctr.present(activityCtr, animated: true)
            
            rowItem.isInProgress = false
            tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            
        }).disposed(by: ctr.bag)
    }
    
    func rewindAction(with rowItem: ProgressItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: Model) {
        
    }
}

enum ExportError: Error {
    case csvDirectory
}

extension ExportError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .csvDirectory:
            return R.string.localizable.csvExportError()
        }
    }
}

extension Invoice {
    
    struct CSV {
        static let empty: String = "-"
        static let separator: String = "; "
    }
    
    var asCSV: String {
        let balance = BalanceModel.balance(for: self)
        let numberCSV = number ?? CSV.empty
        let dateCSV = date?.asString(.short, timeStyle: .none) ?? CSV.empty
        let dueDateCSV = dueTimestamp?.asString(.short, timeStyle: .none) ?? CSV.empty
        let clientCSV = clientName ?? CSV.empty
        
        return numberCSV + CSV.separator + dateCSV + CSV.separator + dueDateCSV + CSV.separator +
            clientCSV + CSV.separator + balance.subtotal + CSV.separator + balance.vat + CSV.separator +
            balance.paid + CSV.separator + balance.balance
    }
}

class BackupModel: Model {
    
    required init(with context: NSManagedObjectContext) {
        super.init(with: context)
        
        let backupFooter: String
        if let date = UserDefaults.lastUploadDate {
            backupFooter = R.string.localizable.restoreFromBackupFooter(date.asString(.medium, timeStyle: .short))
        } else {
            backupFooter = R.string.localizable.restoreFromBackupNoBackupYetFooter()
        }
        
        let obs = Downloader.instance!.progressObservable.map { (progress) -> String? in
            if progress == .none {
                return nil
            }
            return progress.localizedString
        }
        
        let item1 = ProgressItem(image: R.image.download_backup_icon()!, title: R.string.localizable.restoreFromBackup(), isInProgress: false, progressObservable: obs)
        let rows1: [ConfigurableRow] = [
            TableRow<ProgressCell, RestoreBackupAction>(item: item1, action: RestoreBackupAction())
        ]
        let section1 = Section(rows: rows1, footerTitle: backupFooter)
        
        let item2 = ProgressItem(image: R.image.export_csv_icon()!, title: R.string.localizable.exportCSV(), isInProgress: false)
        let rows2: [ConfigurableRow] = [
            TableRow<ProgressCell, ExportCSVAction>(item: item2, action: ExportCSVAction())
        ]
        let section2 = Section(rows: rows2, footerTitle: R.string.localizable.exportCSVFooter())
        
        sections = [section1, section2]
    }
    
    func exportAsCSV() -> Observable<URL> {
        
        let backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        backgroundContext.parent = context
        
        let background = ConcurrentDispatchQueueScheduler(qos: .background)
        return Observable.just(()).observeOn(background).map({ (_) -> URL in
            let filename = R.string.localizable.export() + moment().format("ddmmyyyy") + ".csv"
            guard let directory = FileManagerHelper.createDirectory(.export) else {
                throw ExportError.csvDirectory
            }
            
            let path = directory + filename
            
            let header = R.string.localizable.csvHeader() + "\n"
            let invoices = Invoice.allObjects(matchingPredicate: NSPredicate.undeletedItem(),context: backgroundContext)
            let csv = invoices.reduce(header, { (current, invoice) -> String in
                return current + invoice.asCSV + "\n"
            })
            
            try csv.write(toFile: path, atomically: true, encoding: .utf8)
            return URL(fileURLWithPath: path)
            
        }).observeOn(MainScheduler.instance)
    }
}
