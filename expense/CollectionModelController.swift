//
// Created by Richard Marktl on 2019-04-10.
// Copyright © 2019 meisterwork GmbH. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import RxSwift

class CollectionModelController<DataProvider: Model<UICollectionView>>: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var collectionView: UICollectionView!

    let bag = DisposeBag()
    var context: NSManagedObjectContext!
    var lastSelectedItem: ConfigurableRow?
    var manuallyManageDataUpdate: Bool = false

    lazy var model: DataProvider = { return createModel() }()

    public func createModel() -> DataProvider {
        return DataProvider(with: context)
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
        print("section: \(section), row \(model.sections[section].rows.count)")
        return model.sections[section].rows.count

    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = model.sections[indexPath.section].rows[indexPath.row]
        print(item.reuseIdentifier)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: item.reuseIdentifier, for: indexPath)
        item.configure(cell)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = model.sections[indexPath.section].rows[indexPath.row]
        item.performTap(indexPath: indexPath, sender: collectionView, in: self, model: model)

        if let lastItem = lastSelectedItem, item.identifier != lastItem.identifier {
            // lastItem.rewindAction(tableView: tableView, in: self, model: model) FIXME: improve the rewind action
            lastSelectedItem = nil
        }

        lastSelectedItem = item
    }
}
