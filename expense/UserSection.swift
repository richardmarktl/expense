//
//  UserSection.swift
//  InVoice
//
//  Created by Georg Kitz on 23/01/2018.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import UIKit
import Horreum
import RxSwift
import CoreData

struct UserItem {
    let name: String
    let email: String
}

class UserDetailAction: TapActionable {
    typealias RowActionType = UserItem
    func performTap(with rowItem: UserItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: TableModel) {
        guard let aCtr = R.storyboard.settings.accountDetailViewController() else {
            return
        }
        aCtr.context = model.context
        ctr.navigationController?.pushViewController(aCtr, animated: true)
    }
    
    func rewindAction(with rowItem: UserItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: TableModel) {
        
    }
}

class UserSection: TableSection {
    
    private let bag = DisposeBag()
    
    init(with context: NSManagedObjectContext) {
        
        let account = Account.current(context: context)
        let row1 = UserItem(name: account.name ?? "", email: account.email ?? "")
        
        let rows: [ConfigurableRow] = [
            TableRow<UserCell, UserDetailAction>(item: row1, action: UserDetailAction())
        ]
        
        super.init(rows: rows)
    }
}
