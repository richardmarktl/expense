//
//  ArticleSection.swift
//  InVoice
//
//  Created by Georg Kitz on 26.03.19.
//  Copyright © 2019 meisterwork GmbH. All rights reserved.
//

import Foundation
import RxSwift

class ItemSection: Section {
    
    private let bag = DisposeBag()
    private let showArticleNumber: BoolItem
    private let showArticleTitle: BoolItem
    private let showArticleDescription: BoolItem
    
    init(design: JobDesign) {
        
        showArticleNumber = BoolItem(title: R.string.localizable.showArticleNumber(), defaultData: design.showArticleNumber)
        showArticleTitle = BoolItem(title: R.string.localizable.showArticleTitle(), defaultData: design.showArticleTitle)
        showArticleDescription = BoolItem(title: R.string.localizable.showArticleDescription(), defaultData: design.showArticleDescription)
        
        showArticleNumber.data.asObservable().subscribe(onNext: { [weak design] (value) in
            design?.showArticleNumber = value
            try? design?.managedObjectContext?.save()
        }).disposed(by: bag)
        
        showArticleTitle.data.asObservable().subscribe(onNext: { [weak design] (value) in
            design?.showArticleTitle = value
            try? design?.managedObjectContext?.save()
        }).disposed(by: bag)
        
        showArticleDescription.data.asObservable().subscribe(onNext: { [weak design] (value) in
            design?.showArticleDescription = value
            try? design?.managedObjectContext?.save()
        }).disposed(by: bag)
        
        let rows = [
            TableRow<SwitchCell, NoOperationBoolAction>(item: showArticleNumber, action: NoOperationBoolAction()),
            TableRow<SwitchCell, NoOperationBoolAction>(item: showArticleTitle, action: NoOperationBoolAction()),
            TableRow<SwitchCell, NoOperationBoolAction>(item: showArticleDescription, action: NoOperationBoolAction())
        ]
        
        super.init(rows: rows, headerTitle: R.string.localizable.articleSettings())
    }
}
