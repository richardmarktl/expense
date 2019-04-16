//
// Created by Richard Marktl on 2019-04-10.
// Copyright © 2019 meisterwork GmbH. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import RxSwift

class CollectionModel: Model<UICollectionView> { }

class CollectionModelController<CollectionModelType: CollectionModel>: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var collectionView: UICollectionView!

    let bag = DisposeBag()
    var context: NSManagedObjectContext!
    var manuallyManageDataUpdate: Bool = false

    lazy var model: CollectionModelType = { return createModel() }()

    /// Override point for the lazy Model creation.
    public func createModel() -> CollectionModelType {
        return CollectionModelType(with: context)
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
        return model.numberOfSections()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.numberOfRows(in: section)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let item = model.row(at: indexPath) else {
            fatalError("CollectionModelController no cell at \(indexPath)")
        }

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: item.reuseIdentifier, for: indexPath)
        item.configure(cell)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        model.performTap(at: indexPath, sender: collectionView, in: self)
    }
}
