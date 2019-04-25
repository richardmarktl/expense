//
// Created by Richard Marktl on 2019-04-24.
// Copyright (c) 2019 meisterwork GmbH. All rights reserved.
//

import UIKit
import CommonUI
import CoreDataExtensio
import InvoiceBotSDK

class BudgetCategoryEditViewController: DetailTableModelController<BudgetCategory, BudgetCategoryModel> {
    override open func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(R.nib.textFieldCell)
        tableView.register(R.nib.numberCell)
        tableView.register(R.nib.imageLoadingCell)
        tableView.register(R.nib.addCell)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(done))
    }

    public class func newCategory(with entry: BudgetEntry?) -> BudgetCategoryEditViewController {
        guard let controller = R.storyboard.category.budgetCategoryEditViewController() else {
            fatalError("The BudgetCategoryEditViewController is not in the storyboard.")
        }
        controller.context = CoreDataContainer.instance!.newMainThreadChildContext()
        controller.item =  BudgetCategory.create(in: controller.context)
        if let entry = entry, let realEntry = controller.context.object(with: entry.objectID) as? BudgetEntry {
            controller.item.addToEntries(realEntry)
        }
        return controller
    }

    public class func edit(category: BudgetCategory) -> BudgetCategoryEditViewController {
        guard let controller = R.storyboard.category.budgetCategoryEditViewController() else {
            fatalError("The BudgetCategoryEditViewController is not in the storyboard.")
        }
        controller.context = CoreDataContainer.instance!.newMainThreadChildContext()
        controller.item = category
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