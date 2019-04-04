//
//  FeatureStackView.swift
//  InVoice
//
//  Created by Georg Kitz on 04.10.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import UIKit

@IBDesignable
class FeatureStackView: UIStackView {
    
    // type = 1 means that we show checkmark + feature title
    // type = 2 means that we show title + description of the feature
    @IBInspectable var displayType: Int = 1 {
        didSet {
            setupContent()
        }
    }
    
    private func setupContent() {
        removeAllFeatures()
        
        Feature.all().forEach { (feature) in
            if displayType == 1 {
                addFeatureForDisplayType1(feature: feature)
            } else if displayType == 2 {
                addFeatureForDisplayType2(feature: feature)
            }
        }
    }
    
    private func addFeatureForDisplayType1(feature: Feature) {
        let imageView = UIImageView(image: R.image.upsell_tick())
        imageView.contentMode = .center
        imageView.widthAnchor.constraint(equalToConstant: 14).isActive = true
        imageView.setContentHuggingPriority(UILayoutPriority(rawValue: 251), for: UILayoutConstraintAxis.horizontal)
        imageView.setContentHuggingPriority(UILayoutPriority(rawValue: 251), for: UILayoutConstraintAxis.vertical)
        
        let title = UILabel(for: feature)
        title.font = FiraSans.regular.font(18)
        
        let stackView = UIStackView(arrangedSubviews: [imageView, title])
        stackView.axis = .horizontal
        stackView.spacing = 20
        
        addArrangedSubview(stackView)
    }
    
    private func addFeatureForDisplayType2(feature: Feature) {
        let title = UILabel(for: feature)
        title.font = FiraSans.medium.font(16)
        
        let description = UILabel()
        description.font = FiraSans.regular.font(14)
        description.textColor = UIColor.blueGrayish
        description.text = feature.upsell3Description
        description.numberOfLines = 0
        
        let stack = UIStackView(arrangedSubviews: [title, description])
        stack.axis = .vertical
        
        addArrangedSubview(stack)
    }
    
    private func removeAllFeatures() {
        arrangedSubviews.forEach { (view) in
            removeArrangedSubview(view)
            view.removeFromSuperview()
        }
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        displayType = 1
    }
}

private extension UILabel {
    convenience init(for feature: Feature) {
        self.init()
        textColor = UIColor.blackish
        text = feature.upsell3Title
        numberOfLines = 2
        setContentCompressionResistancePriority(UILayoutPriority.defaultHigh, for: UILayoutConstraintAxis.horizontal)
        setContentCompressionResistancePriority(UILayoutPriority.defaultHigh, for: UILayoutConstraintAxis.vertical)
    }
}
