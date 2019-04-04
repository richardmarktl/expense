//
//  TrialBannerView.swift
//  InVoice
//
//  Created by Georg Kitz on 18.09.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import UIKit
import SwiftRichString
import RxSwift

class TrialBannerView: UIView {
    
    private let label: UILabel = UILabel()
    private let button: UIButton = UIButton(type: .custom)
    
    var tapObservable: Observable<Void> {
        return button.rx.tap.mapToVoid()
    }
    
    init() {
        
        super.init(frame: .zero)
        
        translatesAutoresizingMaskIntoConstraints = false
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.numberOfLines = 0
        button.setContentHuggingPriority(UILayoutPriority(1000), for: UILayoutConstraintAxis.horizontal)
        button.setContentHuggingPriority(UILayoutPriority(1000), for: UILayoutConstraintAxis.vertical)
        
        addSubview(button)
        
        button.topAnchor.constraint(equalTo: topAnchor, constant: 14).isActive = true
        button.leftAnchor.constraint(equalTo: leftAnchor, constant: 14).isActive = true
        button.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14).isActive = true
        button.rightAnchor.constraint(equalTo: rightAnchor, constant: -14).isActive = true
    }
    
    func updateWithState(state: CurrentAccountState.Value) {
        if state == .freeTrail {
            let date = CurrentAccountState.freeAccountExpireDate.asString(.short, timeStyle: .none)
            button.setAttributedTitle(R.string.localizable.trialBannerUntil(date) .set(style: StyleGroup.expireStyleGroup(with: .white)), for: .normal)
            button.setAttributedTitle(R.string.localizable.trialBannerUntil(date) .set(style: StyleGroup.expireStyleGroup(with: UIColor.white.withAlphaComponent(0.5))), for: .highlighted)
            backgroundColor = .greenish
        } else if state == .promo {
            let date = CurrentAccountState.freeAccountExpireDate.asString(.short, timeStyle: .none)
            button.setAttributedTitle(R.string.localizable.promoBannerUntil(date) .set(style: StyleGroup.expireStyleGroup(with: .white)), for: .normal)
            button.setAttributedTitle(R.string.localizable.promoBannerUntil(date) .set(style: StyleGroup.expireStyleGroup(with: UIColor.white.withAlphaComponent(0.5))), for: .highlighted)
            backgroundColor = .greenish
        } else if state == .trialExpired {
            let date = CurrentAccountState.freeAccountExpireDate.asString(.short, timeStyle: .none)
            button.setAttributedTitle(R.string.localizable.trialExpired(date) .set(style: StyleGroup.expireStyleGroup(with: .white)), for: .normal)
            button.setAttributedTitle(R.string.localizable.trialExpired(date) .set(style: StyleGroup.expireStyleGroup(with: UIColor.white.withAlphaComponent(0.5))), for: .highlighted)
            backgroundColor = .redish
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
