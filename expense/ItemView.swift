//
//  ItemView.swift
//  InVoice
//
//  Created by Richard Marktl on 22.11.17.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ItemView: UIView, XibSetupable {
    @IBOutlet weak var nameLabel: UILabel?
    @IBOutlet weak var detailLabel: UILabel?
    
    @IBOutlet weak var tapGesture: UITapGestureRecognizer?
    
    var tapObservable: Observable<UITapGestureRecognizer> {
        return tapGesture?.rx.event.asObservable() ?? Observable.empty()
    }
    
    var item: Item? {
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
        nameLabel?.text = item?.itemDescription
        detailLabel?.text = item?.price?.asString()
    }
}
