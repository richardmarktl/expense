//
//  AddLocalizationModel.swift
//  InVoice
//
//  Created by Georg Kitz on 17.10.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import RxSwift

class AddLocalizationFromLanguageCell: ReusableCell, ConfigurableCell {
    typealias ConfigType = Language
    
    func configure(with item: Language) {
        textLabel?.text = item.shortDesignName + " " + item.longName
    }
}

class CreateLocalizationFromLanguageAction: TapActionable {
    typealias RowActionType = Language
    
    func performTap(with rowItem: Language, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: Model) {
        Analytics.themeCreateLanguageSet.logEvent()
        
        let localization = JobLocalization.create(in: model.context)
        localization.language = rowItem.rawValue
        try? model.context.save()
        
        let saveContext = localization.managedObjectContext
        _ = JobLocalizationRequest.upload(localization).take(1).subscribe(onNext: { (jobLocalization) in
            try? saveContext?.save()
        })
        
        ctr.navigationController?.popViewController(animated: true)
    }
    
    func rewindAction(with rowItem: Language, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: Model) {
        
    }
}

class AddLocalizationFromLanguageSection: Section {
    
    convenience init(context: NSManagedObjectContext) {
        
        let currentLanguages = JobLocalization.allObjects(matchingPredicate: NSPredicate.undeletedItem(), context: context).map { (localization) -> Language in
            return Language.create(from: localization.language ?? "")
        }
        
        var languagesToAdd = Language.all
        languagesToAdd.removeAll { (language) -> Bool in
            return currentLanguages.contains(language)
        }
        
        let rows = languagesToAdd.map { (language) -> ConfigurableRow in
            return TableRow<AddLocalizationFromLanguageCell, CreateLocalizationFromLanguageAction>(item: language, action: CreateLocalizationFromLanguageAction())
        }
        self.init(rows: rows)
    }
}

class AddLocalizationFromLanguageModel: Model {
    required init(with context: NSManagedObjectContext) {
        super.init(with: context)
        sections = [AddLocalizationFromLanguageSection(context: context)]
    }
}
