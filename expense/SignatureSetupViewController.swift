//
//  SignatureSetupViewController.swift
//  InVoice
//
//  Created by Richard Marktl on 04.09.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import UIKit
import RxSwift
import Horreum
import CoreData

class SignatureSetupViewController: TableModelController<SignatureModel> {
    @IBOutlet var removeSignatureButton: ActionButton!
    
    override lazy var model: SignatureModel = {
        let context = Horreum.instance!.mainContext
        let defaults = Account.allObjects(context: context).first!
        return SignatureModel(item: defaults, storeChangesAutomatically: true, deleteAutomatically: true, sections: [], in: context)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = false
            removeConstraint(by: "ios10bottom")
        } else {
            removeConstraint(by: "ios11bottom")
        }
        
        if let topItem = navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        }
        
        title = R.string.localizable.signatureSection()
        removeSignatureButton.title = R.string.localizable.removeSignature()
        removeSignatureButton.tapObservable.subscribe(onNext: { [unowned self] () in
            self.shouldRemoveSignature().filterTrue().subscribe(onNext: { (removed) in
                SignatureViewController.removeSignature()
                self.tableView.reloadData()
                self.removeSignatureButton.button?.isEnabled = false
            }).disposed(by: self.bag)
        }).disposed(by: bag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        removeSignatureButton.button?.isEnabled = SignatureViewController.hasSignatureImage()
    }

    private func shouldRemoveSignature() -> Observable<Bool>{
        return Observable.create({ [weak self] (observer) -> Disposable in
            let alert = UIAlertController(title: R.string.localizable.removeSignature(), message: nil, preferredStyle: .alert)
            let cancel = UIAlertAction(title: R.string.localizable.cancel(), style: UIAlertActionStyle.cancel, handler: { (_) in
                observer.onNext(false)
                observer.onCompleted()
            })

            let disable = UIAlertAction(title: R.string.localizable.remove(), style: UIAlertActionStyle.default, handler: { (_) in
                observer.onNext(true)
                observer.onCompleted()
            })

            alert.addAction(cancel)
            alert.addAction(disable)

            self?.present(alert, animated: true)

            return Disposables.create()
        })
    }
}



