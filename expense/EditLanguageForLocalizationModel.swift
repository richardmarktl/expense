//
//  EditLanguageForLocalizationModel.swift
//  InVoice
//
//  Created by Georg Kitz on 17.10.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation
import CoreData
import RxSwift

class EditLanguageForLocalizationSection: TableSection {
    
    private let bag = DisposeBag()
    private(set) var textEntries: [TextEntry] = []
    
    init(jobLocalization: JobLocalization, context: NSManagedObjectContext) {
        
        super.init(rows: [], footerTitle: R.string.localizable.languageSetEditHelpText())
        
        LanguageLoader.updateCurrentLanguageBundle(to: jobLocalization.language)
        
        let entity = jobLocalization.entity
        textEntries = entity.attributesByName.filter { (attributePair) -> Bool in
                return attributePair.value.attributeType == NSAttributeType.stringAttributeType &&
                    attributePair.key != "uuid" && attributePair.key != "language"
            }
            .sorted(by: { (attr1, attr2) -> Bool in
                return attr1.key < attr2.key
            })
            .map { (attributePair) -> TextEntry in
            
                let placeholder = LanguageLoader.localizedString(attributePair.key, parameters: [])
                let entry = TextEntry(placeholder: placeholder, value: jobLocalization.value(forKey: attributePair.key) as? String)
                entry.value.asObservable().subscribe(onNext: { jobLocalization.setValue($0.databaseValue, forKey: attributePair.key) }).disposed(by: bag)
                return entry
            }
        
        rows = textEntries.map({ (textEntry) -> ConfigurableRow in
            return TableRow<TextFieldCell, FirstResponderActionTextFieldCell>(item: textEntry, action: FirstResponderActionTextFieldCell())
        })
    }
}

class EditLanguageForLocalizationModel: DetailModel<JobLocalization> {
    
    override var saveEnabledObservable: Observable<Bool> {
        return Observable.of(true)
    }
    
    required init(item: JobLocalization, storeChangesAutomatically: Bool, deleteAutomatically: Bool, sections: [TableSection], in context: NSManagedObjectContext) {
        let section = [EditLanguageForLocalizationSection(jobLocalization: item, context: context)]
        super.init(item: item, storeChangesAutomatically: true, deleteAutomatically: true, sections: section, in: context)
        
        let language = Language.create(from: item.language ?? "")
        title = language.shortDesignName + " " + language.longName
    }
    
    required init(with context: NSManagedObjectContext) {
        fatalError("init(with:) has not been implemented")
    }
    
    override func save() -> JobLocalization {
        let val = super.save()
        let saveContext = item.managedObjectContext
        _ = JobLocalizationRequest.upload(item).do(onNext: { (_) in
            try? saveContext?.save()
        }).take(1).subscribe()
        return val
    }
}
