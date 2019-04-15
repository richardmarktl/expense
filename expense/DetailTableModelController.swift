//
//  DetailModelTableViewController.swift
//  InVoice
//
//  Created by Georg Kitz on 18/12/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import Foundation
import CoreData
import CoreDataExtensio
import RxSwift
import RxCocoa

class DetailTableModelController<ItemType, Model: DetailModel<ItemType>>: TableModelController<Model>, AutoScroller {
    @IBOutlet weak var deleteButton: ActionButton?
    @IBOutlet weak var saveButton: ActionButton?
    
    var item: ItemType!
    var cancelAlertTitle: String {
        return ""
    }
    
    private (set) var wasCancelled: Bool = false
    var completionBlock: ((ItemType) -> Void)?
    var removeBlock: (() -> Void)?
    var cancelBlock: (() -> Void)?
    var dismissActionBlock: ((UIViewController) -> Void)?
    var askBeforeDeletion: Bool = true
    
    override public func createModel() -> Model {
        let storeChangesAutomatically = completionBlock == nil
        let deleteAutomatically = removeBlock == nil
        return Model(item: item, storeChangesAutomatically: storeChangesAutomatically, deleteAutomatically: deleteAutomatically, sections: [], in: context)
    }
    
    // members used for the autoscroller implementation
    var scrollViewDefaultInsets: UIEdgeInsets = .zero
    var scrollView: UIScrollView!
    var additionalHeight: CGFloat = 0
    
    class func createWallet() -> UIViewController {
        let ctx = CoreDataContainer.instance!.newMainThreadChildContext()
        //swiftlint:disable force_cast
        let item = ItemType.create(in: ctx) as! ItemType
        //swiftlint:enable force_cast
        return show(item: item, in: ctx)
    }
    
    class func show(item: ItemType, in context: NSManagedObjectContext = CoreDataContainer.instance!.newMainThreadChildContext(),
                    completionBlock: ((ItemType) -> Void)? = nil, removeBlock: (() -> Void)? = nil, cancelBlock: (() -> Void)? = nil) -> UIViewController {
        
        let ctrs = controllers(type: self)
        
        ctrs.1.context = context
        ctrs.1.completionBlock = completionBlock
        ctrs.1.removeBlock = removeBlock
        ctrs.1.cancelBlock = cancelBlock
        
        if item.managedObjectContext! != context {
            //swiftlint:disable force_cast
            ctrs.1.item = (context.object(with: item.objectID) as! ItemType)
            //swiftlint:enable force_cast
        } else {
            ctrs.1.item = item
        }
        
        return ctrs.0
    }
    
    class func controllers<T>(type: T.Type) -> (UIViewController, T) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(R.nib.textFieldCell)
        
        title = model.title
        scrollView = tableView // needed for the autoscroller implementation
        
        setupSaveButton()
        setupDeleteButton()
        setupCancel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerForKeyboardEvents(rx.viewWillDisappear.mapToVoid())
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if model.shouldAutoSelectFirstRowIfNewlyInserted {
            tableView.delegate?.tableView!(tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
        }
    }
    
    private func delete() {
        Analytics.delete.logEvent()
        model.delete()
        if let removeBlock = removeBlock {
            removeBlock()
        } else {
            try? context.save()
        }
        dismiss(animated: true, completion: nil)

    }
    private func setupDeleteButton() {
        
        guard let deleteButton = deleteButton else {
            return
        }
        
        // delete
        if let title = model.deleteButtonTitle {
            deleteButton.title = title
        }
        
        deleteButton.isHidden = model.isDeleteButtonHidden
        deleteButton.tapObservable.subscribe(onNext: { [unowned self] (_) in
            if self.askBeforeDeletion {
                let alert = UIAlertController(title: nil, message: R.string.localizable.deletionDetected(), preferredStyle: UIAlertController.Style.alert)
                let cancel = UIAlertAction(title: R.string.localizable.cancel(), style: UIAlertAction.Style.cancel, handler: nil)
                let save = UIAlertAction(title: R.string.localizable.delete(), style: UIAlertAction.Style.default, handler: { [weak self](_) in
                    self?.delete()
                })
                
                alert.addAction(cancel)
                alert.addAction(save)
                self.present(alert, animated: true)
            } else {
                self.delete()
            }
        }).disposed(by: bag)
    }
    
    private func dismiss() {
        if let dismissActionBlock = self.dismissActionBlock {
            dismissActionBlock(self)
        } else {
            self.dismiss(animated: true)
        }
    }
    
    private func setupSaveButton() {
        
        guard let saveButton = saveButton else {
            return
        }
        
        model.saveEnabledObservable.subscribe(onNext: { (enabled) in
            saveButton.button?.isEnabled = enabled
        }).disposed(by: bag)
        
        saveButton.tapObservable.subscribe(onNext: { [unowned self] (_) in
            Analytics.save.logEvent()
            let item = self.model.save()
            if let completionBlock = self.completionBlock {
                completionBlock(item)
            } else {
                try? self.context.save()
            }
            self.dismiss()
        }).disposed(by: bag)
    }
    
    private func setupCancel() {
        navigationItem.leftBarButtonItem?.rx.tap.asObservable().flatMap({ [unowned self] (_) -> Observable<Bool> in
            Analytics.cancel.logEvent(["hasWarning": self.model.shouldShowCancelWarning.asNSNumber])
            
            self.lastSelectedItem?.rewindAction(tableView: self.tableView, in: self, model: self.model)
            
            if self.completionBlock == nil && self.model.shouldShowCancelWarning {
                return self.cancelAlert(for: self.model)
            } else {
                return Observable.just(true)
            }
        }).subscribe(onNext: { [unowned self](cancelled) in
            
            if let cancelBlock = self.cancelBlock, cancelled {
                cancelBlock()
            }
            self.wasCancelled = true
            self.dismiss()
        }).disposed(by: bag)
    }

    private func cancelAlert(for model: Model) -> Observable<Bool> {
        return Observable.create({ [weak self] (observer) -> Disposable in
            
            let alert = UIAlertController(title: nil, message: R.string.localizable.changesDetected(), preferredStyle: UIAlertController.Style.alert)
            
            let cancel = UIAlertAction(title: R.string.localizable.discard(), style: UIAlertAction.Style.cancel, handler: { (_) in
                observer.onNext(true)
                observer.onCompleted()
            })
            
            let save = UIAlertAction(title: R.string.localizable.save(), style: UIAlertAction.Style.default, handler: { [weak self](_) in
                
                model.save()
                try? self?.context.save()
                
                observer.onNext(false)
                observer.onCompleted()
                
            })
            
            alert.addAction(cancel)
            alert.addAction(save)
            
            self?.present(alert, animated: true)
            
            return Disposables.create()
        })
    }
}
