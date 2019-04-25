//
// Created by Richard Marktl on 2019-04-25.
// Copyright (c) 2019 meisterwork GmbH. All rights reserved.
//

import CommonUI
import ImageViewer
import ImageStorage

class BudgetCategoryImageAction: TapAction<ImageLoadingItem>, GalleryItemsDataSource {

    // The GalleryItemsDataSource provides the items to show
    func itemCount() -> Int {
        return (previewItem != nil) ? 1 : 0
    }

    func provideGalleryItem(_ index: Int) -> GalleryItem {
        return previewItem!
    }

    private var previewItem: GalleryItem?

    override func performTap(with rowItem: ImageLoadingItem, indexPath: IndexPath, sender: UITableView, ctr: UIViewController, model: Model<UITableView>) {
        Analytics.showAttachment.logEvent()

        guard let model = model as? BudgetCategoryModel,
              let data = rowItem.value,
              let filename = data.filename else {
            return
        }

        _ = ImageStorage.loadImage(in: data, for: filename).take(1).subscribe(onNext: { [unowned self](item) in
            self.previewItem = GalleryItem.image {
                $0(item.image)
            }

            let preview = ImagePreviewController(startIndex: 0, itemsDataSource: self)

            preview.closedCompletion = {
                sender.deselectRow(at: indexPath, animated: true)
            }
            preview.swipedToDismissCompletion = preview.closedCompletion

//            preview.changedTitleBlock = { title in
//                rowItem.update(title: title)
//                sender.reloadRows(at: [indexPath], with: .automatic)
//            }

            preview.deleteBlock = {
                model.deleteImage(at: indexPath)
                sender.reloadRows(at: [indexPath], with: .automatic)
            }

            ctr.presentImageGallery(preview)
        })
    }
}
