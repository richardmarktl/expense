//
//  MultipleClientViewCell.swift
//  InVoice
//
//  Created by Richard Marktl on 20.11.17.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import UIKit
import RxSwift

class MultipleSelectionViewCell: ReusableCell, ActionCellProtocol {
    @IBOutlet weak var stackView: UIStackView?
    
    var action: VoiceAction? {
        didSet {
            showClients()
            showItems()
        }
    }
    
    private func showClients() {
        guard let action = action as? MultipleClientSelectionVoiceAction else {
            return
        }
        
        // first remove all the old views
        stackView?.arrangedSubviews.forEach({ (view) in
            view.removeFromSuperview()
        })
        
        // then add all the new client views
        action.clients.forEach { (client) in
            let view = ClientView()
            view.client = client
            view.tapObservable.subscribe(onNext: {(_) in
                action.client = client
                action.touchInputSubject?.onNext(())
            }).disposed(by: reusableBag)
            
            stackView?.addArrangedSubview(view)
        }
    }
    
    private func showItems() {
        guard let action = action as? MultipleItemSelectionVoiceAction else {
            return
        }
        
        // first remove all the old views
        stackView?.arrangedSubviews.forEach({ (view) in
            view.removeFromSuperview()
        })
        
        // then add all the new client views
        action.items.forEach { (item) in
            let view = ItemView()
            view.item = item
            view.tapObservable.subscribe(onNext: {(_) in
                action.item = item
                action.touchInputSubject?.onNext(())
            }).disposed(by: reusableBag)
            
            stackView?.addArrangedSubview(view)
        }
    }
}
