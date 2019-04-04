//
//  ExtraSection.swift
//  InVoice
//
//  Created by Georg Kitz on 27/11/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import Foundation
import CoreData
import RxSwift

private struct Static {
    static let defaultOffset: Int = 2
}

private extension IndexPath {
    
    var normalizedRow: Int {
        return row - Static.defaultOffset
    }
}

class ExtraSection: TableSection {
    
    let bag = DisposeBag()
    let context: NSManagedObjectContext
    let job: Job
    
    let paymentDetail: TextEntry
    let note: TextEntry
    let attachment: AddItem
    
    private(set) var attachments: [Attachment] = []
    
    private let changeSubject: PublishSubject<Void> = PublishSubject()
    override var changedObservable: Observable<Void> {
        return changeSubject.asObservable().skip(1)
    }
    
    init(job: Job, in context: NSManagedObjectContext) {
        
        self.context = context
        self.job = job
        
        paymentDetail = TextEntry(placeholder: R.string.localizable.paymentDetailsTitle(), value: job.paymentDetails ?? "",
                                  autoCapitalizationType: UITextAutocapitalizationType.sentences)
        note = TextEntry(placeholder: R.string.localizable.note(), value: job.note ?? "",
                         autoCapitalizationType: UITextAutocapitalizationType.sentences)
        attachment = AddItem(title: R.string.localizable.addAttachment(), image: R.image.icon_add_attachment()!)
        
        paymentDetail.value.asObservable().debounce(0.75, scheduler: MainScheduler.instance).subscribe(onNext: { (value) in
            job.paymentDetails = value.databaseValue
        }).disposed(by: bag)
        
        paymentDetail.value.asObservable().skip(2).take(1).subscribe(onNext: { _ in
            Analytics.changePaymentDetails.logEvent()
        }).disposed(by: bag)
        
        note.value.asObservable().debounce(0.75, scheduler: MainScheduler.instance).subscribe(onNext: { (value) in
            job.note = value.databaseValue
        }).disposed(by: bag)
        
        note.value.asObservable().skip(2).take(1).subscribe(onNext: { _ in
            Analytics.changeNote.logEvent()
        }).disposed(by: bag)
        
        let rows: [ConfigurableRow] = [
            TableRow<TextViewCell, FirstResponderActionTextViewCell>(item: paymentDetail, action: FirstResponderActionTextViewCell()),
            TableRow<TextViewCell, FirstResponderActionTextViewCell>(item: note, action: FirstResponderActionTextViewCell()),
            TableRow<AddCell, AddAttachmentAction>(item: attachment, action: AddAttachmentAction())
        ]
        
        super.init(rows: rows, headerTitle: R.string.localizable.extras(), footerTitle: R.string.localizable.detailsBottomMessage(job.localizedType))
        
        job.attachmentTyped
            .asSorted()
            .enumerated().forEach({ (item) in
                add(attachment: item.element, at: IndexPath(row: Static.defaultOffset + item.offset, section: 0))
            })
    }
    
    func add(attachment: Attachment, at indexPath: IndexPath) {
        
        if attachment.sort == 0 && indexPath.normalizedRow != 0 {
            attachment.sort = Int16(indexPath.normalizedRow)
        }
        
        let row = TableRow<AttachementCell, AttachmentAction>(item: AttachmentItem(attachment: attachment), action: AttachmentAction())
        insert(tableRow: row, at: indexPath.row)
        attachments.insert(attachment, at: indexPath.normalizedRow)
        
        changeSubject.onNext(())
    }
    
    func update(attachment: Attachment, at indexPath: IndexPath) {
        delete(at: indexPath.row)
        attachments.remove(at: indexPath.normalizedRow)
        
        let row = TableRow<AttachementCell, AttachmentAction>(item: AttachmentItem(attachment: attachment), action: AttachmentAction())
        insert(tableRow: row, at: indexPath.row)
        attachments.insert(attachment, at: indexPath.normalizedRow)
        
        changeSubject.onNext(())
    }
    
    func add(imageAttachment originalImage: UIImage, at indexPath: IndexPath) -> Observable<Void> {
        
        let attachmentItem = AttachmentItem()
        let row = TableRow<AttachementCell, AttachmentAction>(item: attachmentItem, action: AttachmentAction())
        insert(tableRow: row, at: indexPath.row)
        
        guard let convertedImage = originalImage.resized(to: 1600) else {
            return Observable.just(())
        }
        
        return ImageStorage.storeImage(originalImage: convertedImage).do(onNext: { [unowned attachmentItem, unowned self] (storageItem) in
            
            let attachment = Attachment(inContext: self.context)
            attachment.createdTimestamp = Date()
            attachment.updatedTimestamp = Date()
            attachment.fileName = attachmentItem.title
            attachment.job = self.job
            attachment.jobType = Path(with: self.job).rawValue
            attachment.sort = Int16(indexPath.normalizedRow)
            attachment.update(from: storageItem)
            
            self.attachments.insert(attachment, at: indexPath.normalizedRow)
            self.update(attachment: attachment, at: indexPath)
            
        }).mapToVoid()
    }
    
    override func canBeReordered(at indexPath: IndexPath) -> Bool {
        return indexPath.row >= Static.defaultOffset && indexPath.row != rows.count - 1
    }
    
    override func targetIndexPathForReorderFromRow(at sourceIndexPath: IndexPath, to targetIndexPath: IndexPath) -> IndexPath {
        if sourceIndexPath.section != targetIndexPath.section || !canBeReordered(at: targetIndexPath) {
            return sourceIndexPath
        }
        return targetIndexPath
    }
    
    override func reorderRow(at sourceIndexPath: IndexPath, to destIndexPath: IndexPath) {
        super.reorderRow(at: sourceIndexPath, to: destIndexPath)
        
        let attachment = attachments[sourceIndexPath.normalizedRow]
        attachments.remove(at: sourceIndexPath.normalizedRow)
        attachments.insert(attachment, at: destIndexPath.normalizedRow)
        
        attachments.enumerated().forEach { (element) in
            element.element.sort = Int16(element.offset)
        }
        
        changeSubject.onNext(())
    }
    
    func remove(at indexPath: IndexPath) {
        delete(at: indexPath.row)
        
        let attachment = attachments[indexPath.normalizedRow]
        attachment.deletedTimestamp = Date()
        attachment.job = nil
        
        attachments.remove(at: indexPath.normalizedRow)
        
        changeSubject.onNext(())
    }
}
