//
//  BusinessSettingsModel.swift
//  InVoice
//
//  Created by Georg Kitz on 19.02.19.
//  Copyright © 2019 meisterwork GmbH. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import RxSwift

class BusinessSettingsModel: Model {
    
    private let footerUpdate: ReplaySubject<(Int, String)> = ReplaySubject.create(bufferSize: 2)
    private let isValid: ReplaySubject<Bool> = ReplaySubject.create(bufferSize: 1)
    private let invoiceDefaults: Defaults
    private let offerDefaults: Defaults
    
    var footerUpdateObservable: Observable<(Int, String)> {
        return footerUpdate.asObservable()
    }
    
    var isValidObservable: Observable<Bool> {
        return isValid.asObservable()
    }
    
    required init(invoiceDefaults: Defaults, offerDefaults: Defaults, context: NSManagedObjectContext) {
        
        self.invoiceDefaults = invoiceDefaults
        self.offerDefaults = offerDefaults
        
        super.init(with: context)
        
        let prefixInvoiceSection = InvoicePrefixSection(defaults: invoiceDefaults, context: context)
        let prefixOfferSection = InvoicePrefixSection(defaults: offerDefaults, context: context)
        
        sections = [
            InvoiceTextSection(defaults: invoiceDefaults, context: context),
            prefixInvoiceSection,
            BusinessSettingsSection(defaults: invoiceDefaults, context: context),
            InvoiceTextSection(defaults: offerDefaults, context: context),
            prefixOfferSection
        ]
        
        let prefixInvoiceFooterUpdateObs = prefixInvoiceSection
            .footerTitleUpdatedObservable
            .startWith(prefixInvoiceSection.footerTitle)
            .filterNil()
            .map { [unowned self, unowned prefixInvoiceSection](value) -> (Int, String) in
                guard let index = self.sections.firstIndex(of: prefixInvoiceSection) else {
                    return (0, value)
                }
                return (index, value)
            }
        
        let prefixOfferFooterUpdateObs = prefixOfferSection
            .footerTitleUpdatedObservable
            .startWith(prefixOfferSection.footerTitle)
            .filterNil()
            .map { [unowned self, unowned prefixOfferSection](value) -> (Int, String) in
                guard let index = self.sections.firstIndex(of: prefixOfferSection) else {
                    return (0, value)
                }
                return (index, value)
            }
        
        Observable
            .of(prefixInvoiceFooterUpdateObs, prefixOfferFooterUpdateObs)
            .merge()
            .subscribe(onNext: { [weak self](val) in
                self?.footerUpdate.onNext(val)
            })
            .disposed(by: bag)
        
        Observable.combineLatest(prefixInvoiceSection.isSectionValid, prefixOfferSection.isSectionValid, resultSelector: { (valid1, valid2) -> Bool in
            return valid1 && valid2
        }).subscribe(onNext: { [weak self](valid) in
            self?.isValid.onNext(valid)
        })
        .disposed(by: bag)
    }
    
    required init(with context: NSManagedObjectContext) {
        fatalError("init(with:) has not been implemented")
    }
    
    func save() {
        let hasChangedInvoiceValues = invoiceDefaults.changedValues().count > 0
        let hasChangedOfferValues = offerDefaults.changedValues().count > 0
        
        if hasChangedInvoiceValues {
            invoiceDefaults.localUpdateTimestamp = Date()
            _ = DefaultsRequest.upload(invoiceDefaults).take(1).subscribe(onNext: { (defaults) in
                try? defaults.managedObjectContext?.save()
            }, onError: { (error) in
                print(error)
            })
        }
        
        if hasChangedOfferValues {
            offerDefaults.localUpdateTimestamp = Date()
            _ = DefaultsRequest.upload(offerDefaults).take(1).subscribe(onNext: { (defaults) in
                try? defaults.managedObjectContext?.save()
            })
        }
    }
}

fileprivate class DisposableSection: TableSection {
    let bag = DisposeBag()
}

fileprivate class InvoiceTextSection: DisposableSection {
    
    private let note: TextEntry
    private let paymentDetails: TextEntry
    
    required init (defaults: Defaults, context: NSManagedObjectContext) {
        
        let header: String
        if let type = defaults.type, type == Path.invoice.rawValue {
            header = R.string.localizable.businessSettingsInvoice()
        } else {
            header = R.string.localizable.businessSettingsOffer()
        }
        
        note = TextEntry(placeholder: R.string.localizable.note(), value: defaults.note,
                         autoCapitalizationType: UITextAutocapitalizationType.sentences)
        paymentDetails = TextEntry(placeholder: R.string.localizable.paymentDetailsTitle(), value: defaults.paymentDetails,
                                   autoCapitalizationType: UITextAutocapitalizationType.sentences)
        
        let rows: [ConfigurableRow] = [
            TableRow<TextViewCell, FirstResponderActionTextViewCell>(item: note, action: FirstResponderActionTextViewCell()),
            TableRow<TextViewCell, FirstResponderActionTextViewCell>(item: paymentDetails, action: FirstResponderActionTextViewCell())
        ]
        
        super.init(rows: rows, headerTitle: header, footerTitle: R.string.localizable.businessSettingsTextFooter())
        
        note.value.asObservable().subscribe(onNext: { defaults.note = $0.databaseValue.notNil }).disposed(by: bag)
        paymentDetails.value.asObservable().subscribe(onNext: { defaults.paymentDetails = $0.databaseValue.notNil }).disposed(by: bag)
    }
}

extension Int32 {
    var asDecimalNumber: NSDecimalNumber {
        return NSDecimalNumber(value: self)
    }
}

extension Int16 {
    var asDecimalNumber: NSDecimalNumber {
        return NSDecimalNumber(value: self)
    }
}

fileprivate class InvoicePrefixSection: DisposableSection {
    private let prefix: TextEntry
    private let startFrom: NumberEntry
    private let length: NumberEntry
    private let footerNumberFormatter: NumberFormatter = NumberFormatter()
    
    var isSectionValid: Observable<Bool> {
        return prefix.isValidObservable
    }
    
    required init (defaults: Defaults, context: NSManagedObjectContext) {
        
        let prefixTitle: String
        let footerTitle: String
        let footerLocalizationMethod: (String, String) -> String
        if let type = defaults.type, type == Path.invoice.rawValue {
            let prefix = defaults.prefix ?? R.string.localizable.inv()
            prefixTitle = R.string.localizable.businessSettingsPrefixInv()
            footerTitle = R.string.localizable.businessSettingsPrefixFooterInv(prefix, prefix)
            footerLocalizationMethod = R.string.localizable.businessSettingsPrefixFooterInv
        } else {
            let prefix = defaults.prefix ?? R.string.localizable.est()
            prefixTitle = R.string.localizable.businessSettingsPrefixEst()
            footerTitle = R.string.localizable.businessSettingsPrefixFooterEst(prefix, prefix)
            footerLocalizationMethod = R.string.localizable.businessSettingsPrefixFooterEst
        }
        
        let validator: StringValidator = { value -> Bool in
            return value.count > 0 && value.count < 16
        }
        prefix = TextEntry(placeholder: prefixTitle, value: defaults.prefix, autoCapitalizationType: UITextAutocapitalizationType.allCharacters, validator: validator)
        startFrom = NumberEntry(title: R.string.localizable.businessSettingsStartWith(), defaultData: defaults.start.asDecimalNumber, validatorType: .boundaries(-1, INT32_MAX), keyboardType: .numberPad)
        length = NumberEntry(title: R.string.localizable.businessSettingsMinimumLength(), defaultData: defaults.minimumLength.asDecimalNumber, validatorType: .boundaries(-1, 8), keyboardType: .numberPad)
        
        let rows: [ConfigurableRow] = [
            TableRow<TextFieldCell, FirstResponderActionTextFieldCell>(item: prefix, action: FirstResponderActionTextFieldCell()),
            TableRow<NumberCell, FirstResponderActionNumberCell>(item: startFrom, action: FirstResponderActionNumberCell()),
            TableRow<NumberCell, FirstResponderActionNumberCell>(item: length, action: FirstResponderActionNumberCell())
        ]
        
        super.init(rows: rows, footerTitle: footerTitle)
        
        prefix.value.asObservable().subscribe(onNext: {
            defaults.prefix = $0.databaseValue.notNil
        }).disposed(by: bag)
        
        startFrom.data.asObservable().subscribe(onNext: {
            defaults.start = $0.int32Value
        }).disposed(by: bag)
        
        length.data.asObservable().subscribe(onNext: {
            defaults.minimumLength = $0.int16Value
        }).disposed(by: bag)
        
        Observable.combineLatest(prefix.value.asObservable(), startFrom.data.asObservable(), length.data.asObservable()) { [weak self](obs1, obs2, obs3) -> String in
            
            self?.footerNumberFormatter.minimumIntegerDigits = obs3.intValue
            let nextValue = obs1.databaseValue.notNil + (self?.footerNumberFormatter.string(from: obs2 + 1) ?? "")
            return footerLocalizationMethod(nextValue, obs1.databaseValue.notNil)
            
        }.subscribe(onNext: { [weak self] (footerText) in
           self?.updateFooter(to: footerText)
        }).disposed(by: bag)
    }
}

fileprivate class BusinessSettingsSection: DisposableSection {
    
    private let due: NumberEntry
    
    required init (defaults: Defaults, context: NSManagedObjectContext) {
        
        due = NumberEntry(title: R.string.localizable.businessSettingsDueIn(), defaultData: NSDecimalNumber(value: defaults.due))
        
        let rows: [ConfigurableRow] = [
            TableRow<NumberCell, FirstResponderActionNumberCell>(item: due, action: FirstResponderActionNumberCell())
        ]
        
        super.init(rows: rows, footerTitle: R.string.localizable.businessSettingsDueInFooter())
        
        due.data.asObservable().subscribe(onNext: { defaults.due = $0.int16Value }).disposed(by: bag)
    }
}
