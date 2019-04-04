//
//  ErrorViewCell.swift
//  InVoice
//
//  Created by Richard Marktl on 24.11.17.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import UIKit

class ErrorViewCell: UITableViewCell, ActionCellProtocol {
    @IBOutlet weak var label: UILabel!

    var action: VoiceAction? {
        didSet {
            if let action = action as? ErrorVoiceAction {
                label.text = action.voiceInput
            }
        }
    }
}
