//
//  Containable.swift
//  InVoice
//
//  Created by Georg Kitz on 11/11/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import UIKit

public protocol Containable {
    func add(asChildViewController viewController: UIViewController)
    func remove(childViewController viewController: UIViewController)
}

extension Containable where Self: UIViewController {
    
    func add(asChildViewController viewController: UIViewController) {
        
        if let firstChild = childViewControllers.first {
            remove(childViewController: firstChild)
        }
        
        addChildViewController(viewController)
        view.insertSubview(viewController.view, at: 0)
        
        viewController.view.frame = view.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.translatesAutoresizingMaskIntoConstraints = true
        
        viewController.didMove(toParentViewController: self)
    }
    
    func remove(childViewController viewController: UIViewController) {
        viewController.willMove(toParentViewController: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParentViewController()
    }
}
