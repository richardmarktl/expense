//
//  HoverButton.swift
//  InVoice
//
//  Created by Georg Kitz on 10/11/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

@IBDesignable
class HoverButton: UIView, XibSetupable {
    
    @IBOutlet weak var button: UIButton?
    @IBOutlet weak var buttonShadow: UIView?
    
    var tapObservable: Observable<Void> {
        return button?.rx.tap.asObservable() ?? Observable.empty()
    }
    
    @IBInspectable var icon: UIImage? {
        didSet {
            setProperties()
        }
    }
    
    @IBInspectable var title: String? {
        didSet {
            setProperties()
        }
    }
    
    @IBInspectable var imageColor: UIColor = UIColor.main {
        didSet {
            setProperties()
        }
    }
    
    @IBInspectable var imageHighlightedColor: UIColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.12) {
        didSet {
            setProperties()
        }
    }
    
    @IBInspectable var radius: CGFloat = 25 {
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
        button?.setBackgroundImage(UIImage.imageWithColor(imageColor), for: .normal)
        button?.setBackgroundImage(UIImage.imageWithColor(imageHighlightedColor), for: .highlighted)
        button?.layer.cornerRadius = radius
        button?.clipsToBounds = true

        button?.setImage(icon, for: .highlighted)
        button?.setImage(icon, for: .normal)
        button?.setTitle(title, for: .normal)

        buttonShadow?.backgroundColor = imageColor
        buttonShadow?.layer.cornerRadius = radius
        buttonShadow?.layer.shadowColor = UIColor.black.cgColor
        buttonShadow?.layer.shadowOffset = CGSize(width: 2, height: 2)
        buttonShadow?.layer.shadowRadius = 5
        buttonShadow?.layer.shadowOpacity = 0.5
    }
}
