//
//  PersonalizeSection.swift
//  InVoice
//
//  Created by Georg Kitz on 05/01/2018.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import UIKit
import RxSwift

class PersonalizeSection: Section {
    
    private let bag = DisposeBag()
    private let item: Account
    
    init(item: Account) {
        
        self.item = item
        
        let row1 = ColorItem(design: item.design!)
        let action1 = ColorAction()
        let row2 = LogoItem(item: item)
        let action2 = LogoAction()
        
        let rows: [ConfigurableRow] = [
            TableRow<ColorCell, ColorAction>(item: row1, action: action1),
            TableRow<LogoCell, LogoAction>(item: row2, action: action2),
            TableRow<ActionCell, ShowDocumentFieldsAction>(item: ActionItem(title: R.string.localizable.languageSetRename()), action: ShowDocumentFieldsAction())
        ]
        
        super.init(rows: rows)
        
        row1.data.asObservable().debounce(1, scheduler: MainScheduler.instance).subscribe(onNext: { [weak self] (color) in
            self?.item.design?.color = color.hexString
            try? self?.item.design?.managedObjectContext?.save()
        }).disposed(by: bag)
    }
    
    func store(logo originalImage: UIImage) -> Observable<Void> {
        
        if let filename = item.logoFileName {
            ImageStorage.deleteImage(for: filename)
        }
        
        let filename = UUID().uuidString.lowercased()
        item.logoFileName = filename
        item.logoPath = nil
        item.logoThumbPath = nil
        item.logoFile = nil
        
        guard let convertedImage = originalImage.resized(to: 450) else {
            return Observable.just(())
        }
        
        return ImageStorage.storeImage(originalImage: convertedImage, filename: filename).flatMap({ [unowned self] (storageItem) -> Observable<Void> in
            return self.updateAccount(with: storageItem)
        })
    }
    
    func deleteLogo() {
        
        if let filename = item.logoFileName {
            ImageStorage.deleteImage(for: filename)
        }
        
        item.logoPath = nil
        item.logoThumbPath = nil
        item.logoFileName = nil
        item.logoFile = nil
        item.localUpdateTimestamp = Date()
        
        try? item.managedObjectContext?.save()
        
        _ = AccountRequest.deleteLogo(for: item).take(1).subscribe(onNext: { account in
            try? account.managedObjectContext?.save()
        })
    }
    
    private func updateAccount(with logoStorageItem: ImageStorageItem) -> Observable<Void> {
        
        item.logoPath = logoStorageItem.imagePath
        item.logoThumbPath = logoStorageItem.thumbnailPath
        item.logoFileName = logoStorageItem.filename
        item.logoFile = nil
        item.localUpdateTimestamp = Date()
        
        try? item.managedObjectContext?.save()
        
        return AccountRequest.uploadLogo(for: item).take(1).do(onNext: { account in
            try? account.managedObjectContext?.save()
        }).mapToVoid()
    }
}
