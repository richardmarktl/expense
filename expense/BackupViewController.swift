//
//  BackupViewController.swift
//  InVoice
//
//  Created by Georg Kitz on 24/01/2018.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import UIKit

class BackupViewController: TableModelController<BackupModel> {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = tableView.backgroundColor
        
        navigationController?.navigationBar.prefersLargeTitles = false
        
        if let topItem = navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        }
        
        title = R.string.localizable.backup()
    }
}
