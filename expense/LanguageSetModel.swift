//
//  LanguageSetModel.swift
//  InVoice
//
//  Created by Georg Kitz on 17.10.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import UIKit
import CoreData
import RxSwift


/// LanguageSetModel
class LanguageSetModel: Model {
    
    let localizationSection: LocalizationSection
    
    override var sectionsObservable: Observable<[TableSection]> {
        return Observable.combineLatest(super.sectionsObservable, localizationSection.changedObservable.startWith(()), resultSelector: { (items, _) -> [TableSection] in
            return items
        })
    }
    
    required init(with context: NSManagedObjectContext) {
        localizationSection = LocalizationSection(with: context)
        super.init(with: context)
        sections = [localizationSection, AddLocalizationSection()]
    }
    
    func updateEditing(isEditing: Bool) {
        if isEditing {
            sections = [sections[0]]
        } else {
            sections = [sections[0], AddLocalizationSection()]
        }
    }
    
    override func canEdit(at indexPath: IndexPath) -> Bool {
        return indexPath.section == 0
    }
    
    override func delete(at indexPath: IndexPath) {
        if indexPath.section != 0 {
            return
        }
        localizationSection.delete(at: indexPath.row)
    }
}

/// Localization Section
class LocalizationItem: ViewItem<JobLocalization> {
    let language: Language
    override init(item: JobLocalization) {
        let languageCode = item.language ?? ""
        language = Language.create(from: languageCode)
        super.init(item: item)
    }
}

class LocalizationCell: ReusableCell, ConfigurableCell {
    typealias ConfigType = LocalizationItem
    func configure(with item: LocalizationItem) {
        self.textLabel?.text = item.language.shortDesignName + " " + item.language.longName
    }
}

class LocalizationAction: TapActionable {
    typealias RowActionType = LocalizationItem
    
    func performTap(with rowItem: LocalizationItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: Model) {
        Analytics.themeEditLanguageSet.logEvent()
        
        let editCtr = EditLocalizationForLanguageController.show(item: rowItem.item)
        ctr.navigationController?.pushViewController(editCtr, animated: true)
    }
    
    func rewindAction(with rowItem: LocalizationItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: Model) {
        
    }
}

class LocalizationSection: TableSection {
    private let bag = DisposeBag()
    private let changeSubject: PublishSubject<Void> = PublishSubject()
    private(set) var localizationItems: [LocalizationItem] = []
    
    override var changedObservable: Observable<Void> {
        return changeSubject.asObservable()
    }
    
    init(with context: NSManagedObjectContext) {
        super.init(rows: [])
        
        JobLocalization.rxAllObjects(matchingPredicate: NSPredicate.undeletedItem(), context: context).map { [weak self](items) -> [LocalizationItem] in
            let localizationItems: [LocalizationItem] = items.map(LocalizationItem.init)
            self?.localizationItems = localizationItems
            return localizationItems
        }.map { (items) -> [ConfigurableRow] in
            return items.map({ (item) -> ConfigurableRow in
                return TableRow<LocalizationCell, LocalizationAction>(item: item, action: LocalizationAction())
            })
        }.subscribe(onNext: { [weak self] (rows) in
            self?.rows = rows
            self?.changeSubject.onNext(())
        }).disposed(by: bag)
    }
    
    
    override func delete(at idx: Int) {
        let item = localizationItems[idx]
        
        _ = JobLocalizationRequest.delete(item.item).take(1).subscribe()
        item.item.managedObjectContext?.delete(item.item)
        try? item.item.managedObjectContext?.save()
    }
}


/// AddLanguageSection
class AddLanguageAction: TapActionable {
    typealias RowActionType = AddItem
    func performTap(with rowItem: AddItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: Model) {
        guard let addCtr = R.storyboard.languageSet.addLocalizationFromLanguageController() else {
            return
        }
        
        Analytics.themeAddLanguageSet.logEvent()
        
        addCtr.context = model.context
        ctr.navigationController?.pushViewController(addCtr, animated: true)
    }
    
    func rewindAction(with rowItem: AddItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: Model) {
        
    }
}

class AddLocalizationSection: TableSection {
    convenience init() {
        let addLanguage = AddItem(title: R.string.localizable.languageSetAdd(), image: R.image.add_item())
        let rows: [ConfigurableRow] = [
            TableRow<AddCell, AddLanguageAction>(item: addLanguage, action: AddLanguageAction())
        ]
        self.init(rows: rows, footerTitle: R.string.localizable.languageSetAddHelpText())
    }
}
