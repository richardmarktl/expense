//
//  LanguageSetController.swift
//  InVoice
//
//  Created by Georg Kitz on 17.10.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TView: UITableView {
    
    override func insertSubview(_ view: UIView, at index: Int) {
        if (view is UIImageView) {
            print("NOTE: we override adding of UIImageViews here")
            return
        }
        super.insertSubview(view, at: index)
    }
}

class LanguageSetController: TableModelController<LanguageSetModel> {
    
    private var editItem: UIBarButtonItem!
    private var doneItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(R.nib.addCell)
        title = R.string.localizable.languageSet()
        
        if let topItem = navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        }
        
        let editItem = UIBarButtonItem(barButtonSystemItem: .edit, target: nil, action: nil)
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: nil)
        
        editItem.rx.tap.subscribe(onNext: { [weak self](_) in
            self?.navigationItem.rightBarButtonItem = doneItem
        }).disposed(by: bag)
        
        doneItem.rx.tap.subscribe(onNext: { [weak self] (_) in
            self?.navigationItem.rightBarButtonItem = editItem
        }).disposed(by: bag)
        
        Observable.of(editItem.rx.tap.mapToVoid(), doneItem.rx.tap.mapToVoid()).merge().subscribe(onNext: { [weak self] (_) in
            guard let tableView = self?.tableView, let model = self?.model else { return }
            
            let isEditing = !tableView.isEditing
            self?.manuallyManageDataUpdate = true
            
            tableView.beginUpdates()
            model.updateEditing(isEditing: isEditing)
            if isEditing {
                tableView.deleteSections(IndexSet(integer: 1), with: .right)
            } else {
                tableView.insertSections(IndexSet(integer: 1), with: .right)
            }
            tableView.setEditing(isEditing, animated: false)
            tableView.endUpdates()
            
            self?.manuallyManageDataUpdate = false
        }).disposed(by: bag)
        
        navigationItem.rightBarButtonItem = editItem
    }
}
