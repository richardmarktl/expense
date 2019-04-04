//
//  ColorPickerController.swift
//  InVoice
//
//  Created by Georg Kitz on 05/01/2018.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import UIKit
import Color_Picker_for_iOS

class ColorPickerController: UIViewController {
    
    @IBOutlet weak var colorPicker: HRColorPickerView!
    var colorItem: ColorItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = R.string.localizable.chooseColor()
        
        if let topItem = navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        }
        
        colorPicker.color = colorItem.value
        colorPicker.addTarget(self, action: #selector(ColorPickerController.colorDidChanged(_:)), for: UIControlEvents.valueChanged)
    }
    
    @objc func colorDidChanged(_ picker: HRColorPickerView) {
        colorItem.data.value = picker.color
    }
}
