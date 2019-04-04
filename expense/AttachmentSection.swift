//
//  AttachmentSection.swift
//  InVoice
//
//  Created by Georg Kitz on 10.09.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation
import RxSwift

class AttachmentSection: TableSection {
    
    private let bag = DisposeBag()
    
    private let fullWidthItem: BoolItem
    private let titleItem: BoolItem
    
    var fullWidthItemObservable: Observable<Bool> {
        return fullWidthItem.data.asObservable().skip(1)
    }
    
    init(design: JobDesign) {
        
        fullWidthItem = BoolItem(title: R.string.localizable.attachmentFullWidth(), defaultData: design.attachmentFullWidth)
        titleItem = BoolItem(title: R.string.localizable.attachmentHideTitle(), defaultData: design.attachmentHideTitle)
        
        fullWidthItem.data.asObservable().subscribe(onNext: { [weak design] (value) in
            design?.attachmentFullWidth = value
            try? design?.managedObjectContext?.save()
        }).disposed(by: bag)
        
        titleItem.data.asObservable().subscribe(onNext: { [weak design] (value) in
            design?.attachmentHideTitle = value
            try? design?.managedObjectContext?.save()
        }).disposed(by: bag)
        
        let rows = [
            TableRow<SwitchCell, NoOperationBoolAction>(item: fullWidthItem, action: NoOperationBoolAction()),
            TableRow<SwitchCell, NoOperationBoolAction>(item: titleItem, action: NoOperationBoolAction()),
        ]
        
        super.init(rows: rows, headerTitle: R.string.localizable.attachmentSettings())
    }
}
