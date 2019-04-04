//
//  ExtraActions.swift
//  InVoice
//
//  Created by Georg Kitz on 23/11/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import UIKit
import RxSwift
import ImageIO
import QuickLook
import ImageViewer

class AddAttachmentAction: ProTapAction<AddItem> {
    private var imagePickerBehaviour: ImagePickBehaviour?

    override func performTap(with rowItem: AddItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: TableModel) {
        
        if isProExpired {
            super.performTap(with: rowItem, indexPath: indexPath, tableView: tableView, ctr: ctr, model: model)
            return
        }
        
        Analytics.addAttachment.logEvent()
        guard let model = model as? JobModel else {
            return
        }

        let imagePickerBehaviour = ImagePickBehaviour()
        imagePickerBehaviour.rootController = ctr

        let imgObs = imagePickerBehaviour.imageObservable
        let cancelObs = imagePickerBehaviour.cancelObservable

        _ = imgObs.take(1).takeUntil(cancelObs)
                .flatMap({ (originalImage) -> Observable<Void> in

                    let obs = model.extraSection.add(imageAttachment: originalImage, at: indexPath)
                    tableView.insertRows(at: [indexPath], with: .automatic)
                    tableView.reloadRows(at: [indexPath], with: .automatic)
                    return obs
                })
                .subscribe(onNext: { [unowned tableView] (_) in
                    tableView.reloadRows(at: [indexPath], with: .automatic)
                })

        _ = cancelObs.take(1).takeUntil(imgObs).subscribe(onNext: { (_) in
            tableView.reloadRows(at: [indexPath], with: .automatic)
        })

        imagePickerBehaviour.showPickSelector(tableView)

        self.imagePickerBehaviour = imagePickerBehaviour
    }
}

class PreviewItem: NSObject, QLPreviewItem {
    private let attachmentItem: AttachmentItem?

    init(attachmentItem: AttachmentItem?) {
        self.attachmentItem = attachmentItem
        super.init()
    }

    var previewItemURL: URL? {
        return attachmentItem?.imageURL
    }

    var previewItemTitle: String? {
        return attachmentItem?.title
    }
}

class AttachmentAction: ProTapAction<AttachmentItem>, GalleryItemsDataSource {

    // The GalleryItemsDataSource provides the items to show
    func itemCount() -> Int {
        return (previewItem != nil) ? 1 : 0
    }

    func provideGalleryItem(_ index: Int) -> GalleryItem {
        return previewItem!
    }

    private var previewItem: GalleryItem?

    override func performTap(with rowItem: AttachmentItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: TableModel) {
        
        if isProExpired {
            super.performTap(with: rowItem, indexPath: indexPath, tableView: tableView, ctr: ctr, model: model)
            return
        }
        
        Analytics.showAttachment.logEvent()
        
        guard let model = model as? JobModel, let filename = rowItem.value?.uuid else {
            return
        }

        _ = ImageStorage.loadImage(for: filename).take(1).subscribe(onNext: { [unowned self](item) in
            self.previewItem = GalleryItem.image {
                $0(item.image)
            }

            let preview = ImagePreviewController(startIndex: 0, itemsDataSource: self)

            preview.closedCompletion = {
                tableView.deselectRow(at: indexPath, animated: true)
            }
            preview.swipedToDismissCompletion = preview.closedCompletion

            preview.changedTitleBlock = { title in
                rowItem.update(title: title)
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }

            preview.deleteBlock = {
                model.extraSection.remove(at: indexPath)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }

            ctr.presentImageGallery(preview)
        })
    }
}
