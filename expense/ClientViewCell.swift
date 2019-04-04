//
//  ClientViewCell
//  InVoice
//
//  Created by Richard Marktl on 20.11.17.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import UIKit

class ClientViewCell: UITableViewCell, ActionCellProtocol {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var cornerView: CornerView!
    
    var action: VoiceAction? {
        didSet {
            if let clientAction = action as? ClientFoundVoiceAction {
                nameLabel.text = clientAction.client.name
                addressLabel.text = clientAction.client.address
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let view = UIView()
        view.backgroundColor = UIColor.white
        selectedBackgroundView = view
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        cornerView.backgroundColor = highlighted ? cornerView.borderColor : UIColor.white
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        cornerView.backgroundColor = selected ? cornerView.borderColor : UIColor.white
    }
}
