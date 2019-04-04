//
//  ThemeSelectionController.swift
//  InVoice
//
//  Created by Georg Kitz on 05/01/2018.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Horreum
import Crashlytics

class ThemeSelectionController: TableModelController<ThemeModel>, UINavigationControllerDelegate {
    
    @IBOutlet weak var previewButton: ActionButton!
    
    override lazy var model: ThemeModel = {
        let context = Horreum.instance!.mainContext
        let defaults = Account.allObjects(context: context).first!
        return ThemeModel(item: defaults, storeChangesAutomatically: true, deleteAutomatically: true, sections: [], in: context)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(R.nib.switchCell)
        tableView.register(R.nib.actionCell)
        tableView.reloadData()
        
        navigationController?.navigationBar.prefersLargeTitles = false
        
        if let topItem = navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        }
        
        title = R.string.localizable.personalizeHeader()
        
        previewButton.title = R.string.localizable.showPreview()
        previewButton.tapObservable.subscribe(onNext: { [weak self] () in
            guard let ctr: GeneratedPreviewController = R.storyboard.preview.instantiateInitialViewController(), let model = self?.model else {
                return
            }
            
            ctr.job = model.job
            ctr.renderer = model.renderer
            ctr.hideSendButton = true
            
            self?.navigationController?.pushViewController(ctr, animated: true)
            
        }).disposed(by: bag)
        
         _ = model.attachmentFullWidthEnabledObservable.take(1).subscribe(onNext: { [unowned self](_) in
            let alert = UIAlertController(title: R.string.localizable.information(), message: R.string.localizable.attachmentInformation(), preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: R.string.localizable.oK(), style: .cancel, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true)
        })
        
        uploadDesignObserving()
    }
    
    fileprivate func uploadDesignObserving() {
        let navigationCtrWillShowObs = navigationController!.rx.willShow.filter { (value) -> Bool in
            return value.viewController is SettingsController
        }.mapToVoid()
        
        _ = Observable.zip(rx.viewDidDisappear.mapToVoid(), navigationCtrWillShowObs)
            .flatMap({ [weak self] (_) -> Observable<Void> in
                guard let model = self?.model else {
                    Crashlytics.sharedInstance().recordError("Design upload failed because model is already nil")
                    return Observable.just(())
                }
                return model.uploadDesign().take(1)
            })
            .take(1)
            .subscribe()
    }
}
