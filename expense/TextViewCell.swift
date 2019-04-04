//
//  TextViewCell.swift
//  InVoice
//
//  Created by Georg Kitz on 19/11/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import UIKit

class TextViewCell: ReusableCell, ConfigurableCell, InputAccessoryAble {
    
    typealias ConfigType = TextEntry
    
    @IBOutlet weak var textView: PlaceholderTextView!
    
    func configure(with item: TextEntry) {
        textView.text = item.value.value
        textView.placeholderText = item.placeholder
        textView.keyboardType = item.keyboardType
        textView.textContentType = item.textContentType
        textView.autocapitalizationType = item.autoCapitalizationType
        
        textView.rx.text.bind(to: item.value).disposed(by: reusableBag)
        
        registerAccessory(for: textView)
        
        textView.rx.didChange.subscribe { [weak self](_) in
            if let tableView = self?.superview(of: UITableView.self) {
                tableView.beginUpdates()
                tableView.endUpdates()
            }
        }.disposed(by: reusableBag)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textView.floatingPlaceholderColor = UIColor.main
    }
}
