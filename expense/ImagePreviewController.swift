//
// Created by Richard Marktl on 26.01.18.
// Copyright (c) 2018 meisterwork GmbH. All rights reserved.
//

import UIKit
import RxSwift
import ImageIO
import QuickLook
import ImageViewer

typealias TitleChangedBlock = ((String) -> Void)
typealias DeleteBlock = (() -> Void)

class ImagePreviewController: GalleryViewController {
    private let bag = DisposeBag()

    var deleteBlock: DeleteBlock?
    var changedTitleBlock: TitleChangedBlock?

    private var galleryDataSource: GalleryItemsDataSource

    init(startIndex: Int,
         itemsDataSource: GalleryItemsDataSource,
         itemsDelegate: GalleryItemsDelegate? = nil,
         displacedViewsDataSource: GalleryDisplacedViewsDataSource? = nil,
         configuration: GalleryConfiguration = [],
         hasToolbar: Bool = true) {
        
        var bottom: CGFloat = 0
        if let insets = UIApplication.shared.keyWindow?.safeAreaInsets {
            bottom = insets.bottom
        }

        var defaultConfiguration =  [
            GalleryConfigurationItem.deleteButtonMode(.none),
            GalleryConfigurationItem.thumbnailsButtonMode(.none),
            GalleryConfigurationItem.closeLayout(ButtonLayout.pinRight(10, 0)),
            GalleryConfigurationItem.footerViewLayout(FooterLayout.pinBoth(bottom, 0, 0))
        ]
        defaultConfiguration.append(contentsOf: configuration)
        // now add the toolbar and logic contained in this file
        galleryDataSource = itemsDataSource

        super.init(startIndex: startIndex,
                   itemsDataSource: itemsDataSource,
                   itemsDelegate: itemsDelegate,
                   displacedViewsDataSource: displacedViewsDataSource,
                   configuration: defaultConfiguration)

        if hasToolbar {
            let toolBar = UIToolbar()
            toolBar.barStyle = UIBarStyle.black
            toolBar.isTranslucent = true
            toolBar.sizeToFit()
            toolBar.tintColor = .white
            toolBar.isUserInteractionEnabled = true

            toolBar.items = buildToolbarItems()

            footerView = toolBar
        }
    }

    private func buildToolbarItems() -> [UIBarButtonItem] {
        let share = UIBarButtonItem(barButtonSystemItem: .action, target: nil, action: nil)
        let flex = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let edit = UIBarButtonItem(title: R.string.localizable.editTitle(), style: .plain, target: nil, action: nil)
        let delete = UIBarButtonItem(barButtonSystemItem: .trash, target: nil, action: nil)

        // add the delete action
        delete.rx.tap.subscribe(onNext: { [unowned self](_) in
            if let deleteBlock = self.deleteBlock {
                deleteBlock()
            }
            self.dismiss(animated: true, completion: nil)
        }).disposed(by: bag)

        // add the edit title action
        edit.rx.tap.subscribe(onNext: { [unowned self] (_) in
            self.editTitleAlert()
        }).disposed(by: bag)

        // share the image
        share.rx.tap.subscribe(onNext: { [unowned self] (_) in
            self.showShareSheet()
        }).disposed(by: bag)

        // now set the tint color for all items
        let items = [share, flex, edit, flex, delete]
        for item in items {
            item.tintColor = .white
        }
        return items
    }

    private func editTitleAlert() {
        let ctr = UIAlertController(title: R.string.localizable.editTitle(), message: nil, preferredStyle: .alert)

        ctr.addTextField { [unowned self] textField in
            textField.placeholder = self.title
            textField.text = self.title
        }

        let save = UIAlertAction(title: R.string.localizable.save(), style: .default) { [unowned self] _ in

            let title = ctr.textFields![0].text ?? (self.title ?? "")
            if let changedTitleBlock = self.changedTitleBlock {

                changedTitleBlock(title)
                self.dismiss(animated: true, completion: nil)
            }
        }

        let cancel = UIAlertAction(title: R.string.localizable.cancel(), style: .cancel)

        ctr.addAction(save)
        ctr.addAction(cancel)

        present(ctr, animated: true)
    }

    private func showShareSheet() {
        let item = galleryDataSource.provideGalleryItem(currentIndex)
        switch item {

        case .image(let fetchImageBlock):
            fetchImageBlock { image in
                if let image = image {
                    self.showShareSheet(image: image)
                }
            }
        default:
            break
        }
    }

    private func showShareSheet(image: UIImage) {
        let ctr = UIActivityViewController(activityItems: [image], applicationActivities: [])
        present(ctr, animated: true)
    }
}
