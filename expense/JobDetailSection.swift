//
//  JobDetailSection.swift
//  InVoice
//
//  Created by Georg Kitz on 27/11/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import Foundation
import RxSwift
import SwiftMoment

class DateSection: TableSection {
    
    private let bag = DisposeBag()
    
    private let invoiceDate: DateItem
    private var dueDate: DateItem?
    
    init(job: Job) {
    
        invoiceDate = DateItem.date(for: job)
        
        var rows: [ConfigurableRow] = [
            TableRow<DateCell, DateAction>(item: invoiceDate, action: DateAction())
        ]
        
        if let invoice = job as? Invoice {
            
            let dueDate = DateItem.dueDate(for: invoice)
            dueDate.data.asObservable().subscribe(onNext: { (value) in
                invoice.dueTimestamp = value
            }).disposed(by: bag)
            
            rows.append(TableRow<DateCell, DateAction>(item: dueDate, action: DateAction()))
            self.dueDate = dueDate
        }
    
        invoiceDate.data.asObservable().subscribe(onNext: { (value) in
            job.date = value
        }).disposed(by: bag)
        
        super.init(rows: rows)
        
        // update the due date if the invoice date is later than the due date
        invoiceDate.data.asObservable().subscribe(onNext: { [weak self](value) in
            if let dueDate = self?.dueDate?.data, value.timeIntervalSince1970 > dueDate.value.timeIntervalSince1970 {
                dueDate.value = moment(value).add(7, .Days).date
            }
        }).disposed(by: bag)
    }
}

class JobDetailItem: BasicItem<String> {
    var isExpanded: Bool = false
}

class JobDetailAction: TapActionable {
    typealias RowActionType = JobDetailItem
    
    func performTap(with rowItem: JobDetailItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: Model) {
        guard let section = model.sections[0] as? JobDetailSection else {
            return
        }
        
        let isExpanded = section.toggleExpanse()
        
        tableView.beginUpdates()
        
        let indexPaths = [IndexPath(row: 1, section: indexPath.section), IndexPath(row: 2, section: indexPath.section)]
        if isExpanded {
            tableView.insertRows(at: indexPaths, with: .automatic)
        } else {
            tableView.deleteRows(at: indexPaths, with: .automatic)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.endUpdates()
    }
    
    func rewindAction(with rowItem: JobDetailItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: Model) {
    }
}

fileprivate extension Job {
    var detailsSummarized: String {
        var details = "";
        if let languageCode = language {
            let flag = Language.create(from: languageCode).shortDesignName
            details += flag
        }
        if let currency = currency {
            let symbol = Currency.create(from: currency).symbol
            if details.count > 0 {
                details +=  " | "
            }
            details +=  symbol
        }
        return details
    }
}

class JobDetailSection: TableSection {
    
    private let bag = DisposeBag()
    private let job: Job
    
    private let detailItem: JobDetailItem
    private let languageItem: LanguageItem
    private let currencyItem: CurrencyItem
    
    private let additionalRows: [ConfigurableRow]
    
    
    override var changedObservable: Observable<Void> {
        
        return Observable.of(
            languageItem.data.asObservable().mapToVoid(),
            currencyItem.data.asObservable().mapToVoid()
        ).merge()
    }
    
    init(job: Job) {
        
        self.job = job
        
        detailItem = JobDetailItem(title: R.string.localizable.details(), defaultData: job.detailsSummarized)
        languageItem = LanguageItem(for: job)
        currencyItem = CurrencyItem(for: job)
        
        languageItem.data.asObservable().subscribe(onNext: { (value) in
            LanguageLoader.updateCurrentLanguageBundle(to: value.rawValue)
            job.language = value.rawValue
        }).disposed(by: bag)
        
        currencyItem.data.asObservable().subscribe(onNext: { (value) in
            job.currency = value.code
            CurrencyLoader.update(value)
        }).disposed(by: bag)
        
        let rows: [ConfigurableRow] = [
            TableRow<JobDetailCell, JobDetailAction>(item: detailItem, action: JobDetailAction())
        ]
        
        additionalRows = [
            TableRow<LanguageCell, LanguageAction>(item: languageItem, action: LanguageAction()),
            TableRow<CurrencyCell, CurrencyAction>(item: currencyItem, action: CurrencyAction())
        ]
        
        super.init(rows: rows)
    }
    
    func toggleExpanse() -> Bool {
        if rows.count > 1 {
            detailItem.data.value = job.detailsSummarized
            rows = [rows[0]]
            return false
        } else {
            detailItem.data.value = ""
            rows.append(contentsOf: additionalRows)
            return true
        }
    }
}
