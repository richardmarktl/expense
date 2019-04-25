//
// Created by Georg Kitz on 2019-04-25.
// Copyright (c) 2019 meisterwork GmbH. All rights reserved.
//

import RxSwift
import RxCocoa
import UIKit

open class RxImagePickerDelegateProxy: RxNavigationControllerDelegateProxy, UIImagePickerControllerDelegate {
    public init(imagePicker: UIImagePickerController) {
        super.init(navigationController: imagePicker)
    }
}
