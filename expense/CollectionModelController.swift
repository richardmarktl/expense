//
// Created by Richard Marktl on 2019-04-10.
// Copyright (c) 2019 meisterwork GmbH. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import RxSwift

class CollectionModelController<Model: TableModel>: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var collectionView: UICollectionView!

    let bag = DisposeBag()
    var context: NSManagedObjectContext!
    var lastSelectedItem: ConfigurableRow?
    var manuallyManageDataUpdate: Bool = false

    lazy var model: Model = { return createModel() }()

    public func createModel() -> Model {
        return Model(with: context)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // tableView
        collectionView.register(R.nib.createWalletCell)
        collectionView.register(R.nib.walletCell)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let items = collectionView.indexPathsForSelectedItems, items.count > 0  {
            collectionView.deselectItem(at: items[0], animated: true)
        }

        model.sectionsObservable.subscribe(onNext: { [unowned self] (_) in
            if self.manuallyManageDataUpdate {
                return
            }
            self.collectionView.reloadData()
        }).disposed(by: bag)
    }

    // MARK: - CollectionView

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return model.sections.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.sections[section].rows.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = model.sections[indexPath.section].rows[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: item.reuseIdentifier, for: indexPath)
        item.configure(cell)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let nCtr = NewWalletViewController.createWallet()
//        // Analytics.itemNew.logEvent()
//        self.present(nCtr, animated: true)
        let item = model.sections[indexPath.section].rows[indexPath.row]
        // item.performTap(indexPath: indexPath, tableView: tableView, in: self, model: model) FIXME: improve the rewind action

        if let lastItem = lastSelectedItem, item.identifier != lastItem.identifier {
            // lastItem.rewindAction(tableView: tableView, in: self, model: model) FIXME: improve the rewind action
            lastSelectedItem = nil
        }

        lastSelectedItem = item
    }

//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return model.sections[section].headerTitle
//    }
//
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        guard model.sections[section].footerTitle != nil else {
//            return 0
//        }
//        return UITableView.automaticDimension
//    }
//
//    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
//        return 100
//    }
//
//    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        let identifier = R.nib.tableFooterView.name
//        let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: identifier) as? TableFooterView
//        footer?.footerLabel?.attributedText = model.sections[section].footerTitle?.set(style: StyleGroup.headerFooterStyleGroup())
//        return footer
//    }
//
//    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
//        guard let headerView = view as? UITableViewHeaderFooterView else { return }
//        headerView.textLabel?.font = UIFont.headerFooterFont()
//    }
//
//    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
//        return UITableViewCell.EditingStyle.delete
//    }
//
//    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        return model.canEdit(at: indexPath)
//    }
//
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == UITableViewCell.EditingStyle.delete {
//            manuallyManageDataUpdate = true
//            model.delete(at: indexPath)
//            tableView.deleteRows(at: [indexPath], with: .automatic)
//            manuallyManageDataUpdate = false
//        }
//    }
}
