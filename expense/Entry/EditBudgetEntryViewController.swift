//
// Created by Richard Marktl on 2019-04-23.
// Copyright (c) 2019 meisterwork GmbH. All rights reserved.
//

import UIKit
import CommonUI
import InvoiceBotSDK
import CoreDataExtensio


class EditBudgetEntryViewController:  DetailTableModelController<BudgetEntry, BudgetEntryModel> {
    override open func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(R.nib.textFieldCell)
        tableView.register(R.nib.numberCell)
        tableView.register(R.nib.budgetEntrySelectCategoryCell)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(done))
    }

    public class func newEntry(with wallet: BudgetWallet) -> EditBudgetEntryViewController {
        guard let controller = R.storyboard.wallet.editBudgetEntryViewController() else {
            fatalError("The EditBudgetEntryViewController is not in the storyboard.")
        }
        controller.context = CoreDataContainer.instance!.newMainThreadChildContext()
        controller.item =  BudgetEntry.create(in: controller.context)
        controller.item.wallet = controller.context.object(with: wallet.objectID) as? BudgetWallet
        return controller
    }

    public class func edit(entry: BudgetEntry) -> EditBudgetEntryViewController {
        guard let controller = R.storyboard.wallet.editBudgetEntryViewController() else {
            fatalError("The EditBudgetEntryViewController is not in the storyboard.")
        }
        controller.context = CoreDataContainer.instance!.newMainThreadChildContext()
        controller.item = entry
        return controller
    }

    @objc func done() {
        self.dismiss(animated: true, completion: nil)
    }

    override func dismiss(animated flag: Bool, completion: (() -> Void)?) {
        if let navCtr = self.navigationController {
            // in the case we are not the root controller pop it.
            if navCtr.viewControllers.first != self {
                navCtr.popViewController(animated: flag)
                return
            }
        }
        super.dismiss(animated: flag, completion: completion)
    }
}