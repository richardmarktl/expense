//
//  QuestionView.swift
//  InVoice
//
//  Created by Richard Marktl on 13.11.17.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import UIKit

class QuestionViewCell: UITableViewCell, ActionCellProtocol {
    @IBOutlet weak var label: UILabel!
    
    var action: VoiceAction? {
        didSet {
            label.text = action?.voiceOutput
        }
    }
}
