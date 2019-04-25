//
// Created by Richard Marktl on 2019-04-25.
// Copyright (c) 2019 meisterwork GmbH. All rights reserved.
//

import RxSwift
import ImageStorage

struct ImageData: Directory {
    let filename: String?
    let fileURL: String?
    let name: String
}


class ImageLoadingItem: BasicItem<ImageData?> {

    var thumbImage: Observable<UIImage> {
        guard let data = value, let filename = data.filename else {
            return Observable.empty()
        }

        let obs: Observable<ImageStorageItem>
        if let url = data.fileURL, ImageStorage.hasItemStoredOnFileSystem(in: data, filename: filename) == false {
            obs = ImageStorage.download(fromURL: url, filename: filename, storeIn: data)
        } else {
            obs = ImageStorage.loadImage(in: data, for: filename)
        }

        return obs.map {
            $0.thumbnail
        }
    }
}
