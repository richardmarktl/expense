//
// Created by Richard Marktl on 2019-04-10.
// Copyright © 2019 meisterwork GmbH. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import RxSwift

open class CollectionModelController<CollectionModelType: Model<UICollectionView>>: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet public weak var collectionView: UICollectionView!

    public let bag = DisposeBag()
    public var context: NSManagedObjectContext!
    public var manuallyManageDataUpdate: Bool = false

    public lazy var model: CollectionModelType = {
        return createModel()
    }()

    /// Override point for the lazy Model creation.
    open func createModel() -> CollectionModelType {
        return CollectionModelType(with: context)
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let items = collectionView.indexPathsForSelectedItems, items.count > 0 {
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

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return model.numberOfSections()
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.numberOfRows(in: section)
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let item = model.row(at: indexPath) else {
            fatalError("CollectionModelController no cell at \(indexPath)")
        }

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: item.reuseIdentifier, for: indexPath)
        item.configure(cell)
        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        model.performTap(at: indexPath, sender: collectionView, in: self)
    }
}
