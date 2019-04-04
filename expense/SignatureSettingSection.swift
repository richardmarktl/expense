//
//  SignatureSettingSection.swift
//  InVoice
//
//  Created by Richard Marktl on 04.09.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation
import RxSwift

/// SignatureItem
class SignatureItem: BasicItem<Account> {
    var hasSignature: Bool {
        return SignatureViewController.hasSignatureImage()
    }
    
    var signatureImage: Observable<UIImage> {
        return SignatureViewController.signatureImage()
    }
    
    init(item: Account) {
        super.init(title: "", defaultData: item)
    }
}

/// ColorAction
class SignatureSettingAction: TapActionable {
    typealias RowActionType = SignatureItem
    var doAction: Bool
    
    required init (action: Bool = false) {
        doAction = action
    }
    
    func performTap(with rowItem: SignatureItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: TableModel) {
        guard let signature: SignatureViewController = R.storyboard.signature.instantiateInitialViewController(), doAction else {
            return
        }
        
        // did cancel remove
        Analytics.createSignature.logEvent()
        ctr.navigationController?.pushViewController(signature, animated: true)
    }
    
    func rewindAction(with rowItem: SignatureItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: TableModel) {
        
    }
}


class SignatureSettingSection: TableSection {
    private let bag = DisposeBag()
    private let item: Account
    
    init(item: Account) {
        
        self.item = item
        
        let row1 = SignatureItem(item: item)
        let action1 = SignatureSettingAction()
        let action2 = SignatureSettingAction()
        let action3 = SignatureSettingAction(action: true)
        
        let rows: [ConfigurableRow] = [
            TableRow<SignatureImageCell, SignatureSettingAction>(item: row1, action: action1),
            TableRow<SignatureNameCell, SignatureSettingAction>(item: row1, action: action2),
            TableRow<SignatureControlCell, SignatureSettingAction>(item: row1, action: action3),
        ]
        
        super.init(rows: rows)
    }
}
