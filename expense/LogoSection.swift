//
//  LogoSection.swift
//  InVoice
//
//  Created by Georg Kitz on 27.03.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import UIKit
import RxSwift
import ImageViewer

/// LogoAction
class LogoAction: TapActionable, GalleryItemsDataSource {
    
    // The GalleryItemsDataSource provides the items to show
    func itemCount() -> Int {
        return (previewItem != nil) ? 1 : 0
    }
    
    func provideGalleryItem(_ index: Int) -> GalleryItem {
        return previewItem!
    }
    
    private var previewItem: GalleryItem?
    
    private var imagePickerBehaviour: ImagePickBehaviour?
    typealias RowActionType = LogoItem
    
    func performTap(with rowItem: LogoItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: TableModel) {
        
        Analytics.themeLogo.logEvent()
        
        guard let model = model as? ThemeModel else {
            return
        }
        
        if !rowItem.hasLogo {
            Analytics.themeLogoPick.logEvent()
            showImagePicker(indexPath: indexPath, tableView: tableView, in: ctr, section: model.personalizeSection)
        } else {
            
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
            let cancel = UIAlertAction(title: R.string.localizable.cancel(), style: .cancel)
            let delete = UIAlertAction(title: R.string.localizable.delete(), style: .destructive) { [unowned model](_) in
                Analytics.themeLogoDelete.logEvent()
                model.personalizeSection.deleteLogo()
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            let change = UIAlertAction(title: R.string.localizable.change(), style: UIAlertActionStyle.default) { [unowned model, weak self](_) in
                Analytics.themeLogoChange.logEvent()
                self?.showImagePicker(indexPath: indexPath, tableView: tableView, in: ctr, section: model.personalizeSection)
            }
            let show = UIAlertAction(title: R.string.localizable.show(), style: UIAlertActionStyle.default) { [weak self] (_) in
                Analytics.themeLogoShow.logEvent()
                self?.showPreview(with: rowItem, indexPath: indexPath, tableView: tableView, ctr: ctr, section: model.personalizeSection)
            }
            actionSheet.addAction(cancel)
            actionSheet.addAction(show)
            actionSheet.addAction(change)
            actionSheet.addAction(delete)
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                actionSheet.popoverPresentationController?.sourceView = tableView.cellForRow(at: indexPath)
                actionSheet.popoverPresentationController?.sourceRect = tableView.cellForRow(at: indexPath)?.bounds ?? CGRect.zero
            }
            ctr.present(actionSheet, animated: true)
        }
    }
    
    func rewindAction(with rowItem: LogoItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: TableModel) {
        
    }
    
    private func showPreview(with rowItem: LogoItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, section: PersonalizeSection) {
        
        guard let filename = rowItem.value.logoFileName else {
            return
        }
        
        _ = ImageStorage.loadImage(for: filename).take(1).subscribe(onNext: { [unowned self](item) in
            self.previewItem = GalleryItem.image {
                $0(item.image)
            }
            
            let preview = ImagePreviewController(startIndex: 0, itemsDataSource: self, hasToolbar: false)
            
            preview.closedCompletion = {
                tableView.deselectRow(at: indexPath, animated: true)
            }
            preview.swipedToDismissCompletion = preview.closedCompletion
            
            ctr.presentImageGallery(preview)
        })
    }
    
    private func showImagePicker(indexPath: IndexPath, tableView: UITableView, in ctr: UIViewController, section: PersonalizeSection) {
        let imagePickerBehaviour = ImagePickBehaviour(allowEditing: true)
        imagePickerBehaviour.rootController = ctr
        
        let imgObs = imagePickerBehaviour.imageObservable
        let cancelObs = imagePickerBehaviour.cancelObservable
        
        _ = imgObs.take(1).takeUntil(cancelObs)
            .flatMap({ (originalImage) -> Observable<Void> in
                
                let obs = section.store(logo: originalImage)
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

/// LogoItem
class LogoItem: BasicItem<Account> {
    
    override var title: String {
        get {
            return value.logoFileName == nil ? R.string.localizable.addYourLogo() : R.string.localizable.changeYourLogo()
        }
        set {
            
        }
    }
    
    var hasLogo: Bool {
        return value.logoFileName != nil
    }
    
    var isLoadingLogo: Bool {
        return value.logoFileName != nil && value.logoThumbPath == nil
    }
    
    var thumbImage: Observable<UIImage?> {
        guard let filename = value.logoFileName else { return Observable.just(nil) }

        let obs: Observable<ImageStorageItem>
        if let url = value.logoFile, ImageStorage.hasItemStoredOnFileSystem(filename: filename) == false {
            obs = ImageStorage.download(fromURL: url, filename: filename)
        } else {
            obs = ImageStorage.loadImage(for: filename)
        }

        return obs.map { item in
            return item.thumbnail
        }
    }
    
    init(item: Account) {
        super.init(title: "", defaultData: item)
    }
}
