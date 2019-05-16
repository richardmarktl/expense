//
//  DetailModelTableViewController.swift
//  InVoice
//
//  Created by Georg Kitz on 18/12/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import CoreData
import CoreDataExtensio
import CommonUtil

open class DetailTableModelController<ItemType, Model: DetailModel<ItemType, UITableView>>: TableModelController<Model>, AutoScroller {
    @IBOutlet weak var deleteButton: ActionButton?
    @IBOutlet weak var saveButton: ActionButton?

    public var item: ItemType!
    public var cancelAlertTitle: String {
        return ""
    }

    private (set) public var wasCancelled: Bool = false
    public var completionBlock: ((ItemType) -> Void)?
    public var removeBlock: (() -> Void)?
    public var cancelBlock: (() -> Void)?
    public var dismissActionBlock: ((UIViewController) -> Void)?
    public var askBeforeDeletion: Bool = true

    override open func createModel() -> Model {
        let storeChangesAutomatically = completionBlock == nil
        let deleteAutomatically = removeBlock == nil
        return Model(item: item, storeChangesAutomatically: storeChangesAutomatically, deleteAutomatically: deleteAutomatically, sections: [], in: context)
    }

    // members used for the auto scroller implementation
    public var scrollViewDefaultInsets: UIEdgeInsets = .zero
    public var scrollView: UIScrollView!
    public var additionalHeight: CGFloat = 0

    open class func createItem() -> UIViewController {
        let ctx = CoreDataContainer.instance!.newMainThreadChildContext()
        //swiftlint:disable force_cast
        let item = ItemType.create(in: ctx) as! ItemType
        //swiftlint:enable force_cast
        return show(item: item, in: ctx)
    }

    public class func show(item: ItemType,
                           in context: NSManagedObjectContext = CoreDataContainer.instance!.newMainThreadChildContext(),
                           completionBlock: ((ItemType) -> Void)? = nil,
                           removeBlock: (() -> Void)? = nil,
                           cancelBlock: (() -> Void)? = nil) -> UIViewController {
        let controllers = self.controllers(type: self)
        
        controllers.1.context = context
        controllers.1.completionBlock = completionBlock
        controllers.1.removeBlock = removeBlock
        controllers.1.cancelBlock = cancelBlock

        if item.managedObjectContext! != context {
            //swiftlint:disable force_cast
            controllers.1.item = (context.object(with: item.objectID) as! ItemType)
            //swiftlint:enable force_cast
        } else {
            controllers.1.item = item
        }

        return controllers.0
    }

    open class func controllers<T>(type: T.Type) -> (UIViewController, T) {
        fatalError()
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        title = model.title
        scrollView = tableView // needed for the auto scroller implementation

        setupSaveButton()
        setupDeleteButton()
        setupCancel()
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerForKeyboardEvents(rx.viewWillDisappear.mapToVoid())
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if model.shouldAutoSelectFirstRowIfNewlyInserted {
            tableView.delegate?.tableView!(tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
        }
    }

    private func delete() {
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
                let deletionDetected = PodLocalizedString("Are you sure you want to delete this?")
                let cancelString = PodLocalizedString("Cancel")
                let deleteString = PodLocalizedString("Delete")
                let alert = UIAlertController(title: nil, message: deletionDetected, preferredStyle: UIAlertController.Style.alert)
                let cancel = UIAlertAction(title: cancelString, style: UIAlertAction.Style.cancel, handler: nil)
                let save = UIAlertAction(title: deleteString, style: UIAlertAction.Style.default, handler: { [weak self](_) in
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
            self.model.rewindLastAction(sender: self.tableView, in: self)

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
            let changes = PodLocalizedString("You made some changes.\n\nShould the changes be saved?")
            let discard = PodLocalizedString("Discard")
            let store = PodLocalizedString("Save")

            let alert = UIAlertController(title: nil, message: changes, preferredStyle: UIAlertController.Style.alert)
            let cancel = UIAlertAction(title: discard, style: UIAlertAction.Style.cancel, handler: { (_) in
                observer.onNext(true)
                observer.onCompleted()
            })
            let save = UIAlertAction(title: store, style: UIAlertAction.Style.default, handler: { [weak self](_) in

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
