//
//  AddLanguageController.swift
//  InVoice
//
//  Created by Georg Kitz on 17.10.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import UIKit
class AddLocalizationFromLanguageController: TableModelController<AddLocalizationFromLanguageModel> {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = R.string.localizable.languageSetAdd()
        
        if let topItem = navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        }
    }
}
