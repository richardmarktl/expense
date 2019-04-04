//
// Created by Georg Kitz on 20/02/16.
// Copyright (c) 2016 meisterwork GmbH. All rights reserved.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift
import Photos
import ImageIO

enum ImagePickerError: Error {
    case noOriginalImage
}

class ImagePickBehaviour {
    
    fileprivate var bag = DisposeBag()
    fileprivate var image: PublishSubject<UIImage> = PublishSubject()
    fileprivate var cancel: PublishSubject<Void> = PublishSubject()
    fileprivate let allowEditing: Bool
    
    init(allowEditing: Bool = false) {
        self.allowEditing = allowEditing
    }
    
    var imageObservable: Observable<UIImage> {
        return image.asObservable()
    }
    
    var cancelObservable: Observable<Void> {
        return cancel.asObservable()
    }
    
    @IBOutlet weak var rootController: UIViewController!
    
    @IBAction func showPickSelector(_ sender: AnyObject!) {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: NSLocalizedString("Camera", comment: ""), style: .default) { [unowned self] _ -> Void in
            self.checkPermissionAndPresentImagePicker(with: .camera)
        }
        
        let pickerAction = UIAlertAction(title: NSLocalizedString("Library", comment: ""), style: .default) { [unowned self] _ -> Void in
            self.checkPermissionAndPresentImagePicker(with: .photoLibrary)
        }
        
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { [unowned self] _ -> Void in
            self.cancel.onNext(())
        }
        
        alert.addAction(cameraAction)
        alert.addAction(pickerAction)
        alert.addAction(cancel)
        
        if let tableView = sender as? UITableView, let indexPath = tableView.indexPathForSelectedRow {
            if UIDevice.current.userInterfaceIdiom == .pad {
                alert.popoverPresentationController?.sourceView = tableView.cellForRow(at: indexPath)
                alert.popoverPresentationController?.sourceRect = tableView.cellForRow(at: indexPath)?.bounds ?? CGRect.zero
            }
        }
        
        rootController.present(alert, animated: true, completion: nil)
    }
    
    fileprivate func checkPermissionAndPresentImagePicker(with pickerType: UIImagePickerControllerSourceType) {
        
        let check = ImagePickPermissionCheck(controller: rootController)
        _ = check.checkPermission(for: pickerType).take(1).subscribe(onNext: { [unowned self] _ in
            self.presentImagePicker(with: pickerType)
            }, onError: { error in
                logger.error("ImagePickPermission Error: \(error)")
        })
    }
    
    fileprivate func presentImagePicker(with pickerType: UIImagePickerControllerSourceType) {
        bag = DisposeBag()
        let allowEditing = self.allowEditing
        _ = UIImagePickerController.rx.createWithParent(rootController, animated: true) { (picker) in
            picker.sourceType = pickerType
            picker.allowsEditing = allowEditing
        }.flatMap {
            $0.rx.didFinishPickingMediaWithInfo
        }
        .take(1)
        .map { (info) -> UIImage in
        
            guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
                throw ImagePickerError.noOriginalImage
            }
            
            guard let croppedImage = info[UIImagePickerControllerEditedImage] as? UIImage else {
                return image
            }
            
            return croppedImage
            
        }.bind(to: self.image)
    }
}
