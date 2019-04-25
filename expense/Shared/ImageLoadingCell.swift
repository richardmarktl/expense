//
// Created by Richard Marktl on 2019-04-25.
// Copyright (c) 2019 meisterwork GmbH. All rights reserved.
//

import CommonUI

class ImageLoadingCell: ReusableTableViewCell, ConfigurableCell {
    typealias ConfigType = ImageLoadingItem

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var thumbImageView: UIImageView!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!

    func configure(with item: ImageLoadingItem) {

        titleLabel.text = item.title

        indicatorView.startAnimating()
        thumbImageView.isHidden = true
        indicatorView.isHidden = false

        thumbImageView.layer.cornerRadius = 4
        thumbImageView.clipsToBounds = true

        item.thumbImage.subscribe(onNext: { [weak self] (image) in
            self?.thumbImageView.image = image
            self?.thumbImageView.isHidden = false
            self?.indicatorView.isHidden = true
        }).disposed(by: reusableBag)
    }
}