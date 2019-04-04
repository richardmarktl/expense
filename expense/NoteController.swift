//
//  NoteController.swift
//  InVoice
//
//  Created by Georg Kitz on 20/12/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import UIKit

class NoteController: DetailTableModelController<Account, NoteModel> {
    
    override class func controllers<T>(type: T.Type) -> (UINavigationController, T) {
        guard let nCtr = R.storyboard.settings.noteRootViewRootController(), let ctr = nCtr.childViewControllers.first as? T else {
            fatalError()
        }
        return (nCtr, ctr)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        deleteButton?.isHidden = true
    }
}
