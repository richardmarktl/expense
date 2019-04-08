//
//  XibSetupable.swift
//  InVoice
//
//  Created by Georg Kitz on 10/11/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import UIKit

/// Allows to instanciate views from xibs
public protocol XibSetupable {
    var rootView: UIView? {get}
    func setupFromXib()
}

/// MARK: - XibSetupable implementation
/// How to use:
/// - Create 2 files, a `swift` class of your view + a `xib` and give both the same name
/// - The view loaded from the xib will be the `rootView` of your swift file, that's a little hack to make that work
/// - In the xib file set the file owner to the swift file you created
/// - Connect outlets if you need to
public extension XibSetupable where Self: UIView {

    /// the view we loaded from the nib
    var rootView: UIView? {
        return self.subviews.filter { $0.tag == 190 }.first
    }
    
    /// loads the rootview from the nib and adds it to this view as a child
    func setupFromXib() {
        
        guard let rootView = loadViewFromNib() else {
            logger.error("Couldn't add rootView")
            return
        }
        
        rootView.frame = bounds
        rootView.tag = 190
        rootView.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
        addSubview(rootView)
    }
    
    /// substrings the current name of the class that is using this protocol and tries to load a nib with the name
    /// we extracted
    /// - Returns: the loaded view
    fileprivate func loadViewFromNib() -> UIView? {
        
        let typeOfSelf = type(of: self)
        let bundle = Bundle(for: typeOfSelf)
        
        guard let className = typeOfSelf.description().components(separatedBy: ".").last else {
            return nil
        }
        
        let nib = UINib(nibName: className, bundle: bundle)
        guard let view = nib.instantiate(withOwner: self, options: nil)[0] as? UIView else {
            return nil
        }
        
        return view
    }
}
