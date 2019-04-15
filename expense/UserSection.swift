//
//  UserSection.swift
//  InVoice
//
//  Created by Georg Kitz on 23/01/2018.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import UIKit
import RxSwift
import CoreData

struct UserItem {
    let name: String
    let email: String
}

class UserDetailAction: TapActionable {
    var analytics: (() -> ())?

    typealias RowActionType = UserItem
    typealias SenderType = UITableView

    func performTap(with rowItem: UserItem, indexPath: IndexPath, sender: UITableView, ctr: UIViewController, model: Model<UITableView>) {
//        guard let aCtr = R.storyboard.settings.accountDetailViewController() else {
//            return
//        }
//        aCtr.context = model.context
//        ctr.navigationController?.pushViewController(aCtr, animated: true)
    }
    
    func rewindAction(with rowItem: UserItem, indexPath: IndexPath, sender: UITableView, ctr: UIViewController, model: Model<UITableView>) {
        
    }
}

class UserSection: TableSection<UITableView> {
    private let bag = DisposeBag()
    
    init(with context: NSManagedObjectContext) {
        
        // let account = Account.current(context: context)
        // let row1 = UserItem(name: account.name ?? "", email: account.email ?? "")
        
        // TODO: replace this with the right account.
        let row1 = UserItem(name: "Test Account", email: "test@email.com")
        
        let rows: [Row<UITableView>] = [
            TableRow<UserCell, UserDetailAction>(item: row1, action: UserDetailAction())
        ]
        
        super.init(rows: rows)
    }
}
