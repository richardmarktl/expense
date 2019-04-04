//
//  EditLocalizationForLanguageController.swift
//  InVoice
//
//  Created by Georg Kitz on 17.10.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import UIKit

class EditLocalizationForLanguageController: DetailTableModelController<JobLocalization, EditLanguageForLocalizationModel> {
    
    override class func controllers<T>(type: T.Type) -> (UIViewController, T) {
        guard let ctr = R.storyboard.languageSet.editLocalizationForLanguageController(), let editCtr = ctr as? T else {
            fatalError()
        }
        return (ctr, editCtr)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(R.nib.textFieldCell)
        
        if let topItem = navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        _ = model.save()
    }
}
