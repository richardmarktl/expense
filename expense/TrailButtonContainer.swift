//
//  TrailButtonContainer.swift
//  InVoice
//
//  Created by Georg Kitz on 06/03/2018.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import UIKit
import RxSwift

@IBDesignable
class TrailButtonContainer: UIView, XibSetupable {
    
    @IBOutlet weak var button: BuyButton?
    
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var bottomLabel: UILabel!
    @IBOutlet weak var backgroundView: UIImageView!
    
    @IBInspectable var color: UIColor = UIColor.greenish {
        didSet {
            setupProperties()
        }
    }
    
    @IBInspectable var highlightColor: UIColor = UIColor.greenishHighlighted {
        didSet {
            setupProperties()
        }
    }
    
    var topText: String? {
        set {
            topLabel.text = newValue
        }
        get {
            return topLabel.text
        }
    }
    
    var bottomText: String? {
        set {
            bottomLabel.text = newValue
        }
        get {
            return bottomLabel.text
        }
    }
    
    var tapObservable: Observable<Void> {
        return button?.rx.controlEvent(.touchUpInside).mapToVoid().asObservable() ?? Observable.empty()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupFromXib()
        setupProperties()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupFromXib()
        setupProperties()
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width, height: 52)
    }
    
    func setupProperties() {
        backgroundView?.image = UIImage.imageWithColor(color, cornerRadius: 4.0)
        backgroundView?.highlightedImage = UIImage.imageWithColor(highlightColor, cornerRadius: 4.0)
    }
}
