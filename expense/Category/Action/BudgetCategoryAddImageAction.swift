//
// BudgetCategoryAddImageAction.swift
// expense
//
// Created by Richard Marktl on 2019-04-25.
// Copyright (c) 2019 meisterwork GmbH. All rights reserved.
//

import UIKit
import CommonUI
import RxSwift
import RxCocoa
import ImageIO
import QuickLook
import ImageViewer


class BudgetCategoryAddImageAction: TapAction<AddItem> {
    private var imagePickerBehaviour: ImagePickBehaviour?

    override func performTap(with rowItem: AddItem,
                             indexPath: IndexPath,
                             sender: UITableView,
                             ctr: UIViewController, model: Model<UITableView>) {

        Analytics.categoryAddImage.logEvent()
        guard let model = model as? BudgetCategoryModel else {
            return
        }

        let imagePickerBehaviour = ImagePickBehaviour()
        imagePickerBehaviour.rootController = ctr

        let imgObs = imagePickerBehaviour.imageObservable
        let cancelObs = imagePickerBehaviour.cancelObservable

        _ = imgObs.take(1).takeUntil(cancelObs)
                .flatMap({ (originalImage) -> Observable<Void> in
                    return model.add(image: originalImage, at: indexPath)
                })
                .subscribe(onNext: { [unowned sender] (_) in
                    sender.reloadRows(at: [indexPath], with: .automatic)
                })

        _ = cancelObs.take(1).takeUntil(imgObs).subscribe(onNext: { (_) in
            sender.reloadRows(at: [indexPath], with: .automatic)
        })

        imagePickerBehaviour.showPickSelector(sender)

        self.imagePickerBehaviour = imagePickerBehaviour
    }
}
