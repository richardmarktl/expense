//
//  ClientView.swift
//  InVoice
//
//  Created by Richard Marktl on 20.11.17.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ClientView: UIView, XibSetupable {
    @IBOutlet weak var nameLabel: UILabel?
    @IBOutlet weak var addressLabel: UILabel?
    
    @IBOutlet weak var tapGesture: UITapGestureRecognizer?
    
    var tapObservable: Observable<UITapGestureRecognizer> {
        return tapGesture?.rx.event.asObservable() ?? Observable.empty()
    }
    
    var client: Client? {
        didSet {
            setProperties()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupFromXib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupFromXib()
        setProperties()
    }
    
    private func setProperties() {
        nameLabel?.text = client?.name
        addressLabel?.text = client?.address
    }
}
