//
//  EmptyViewController.swift
//  InVoice
//
//  Created by Georg Kitz on 15/01/2018.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

protocol EmptyViewable {
    var emptyViewInsertBelowView: UIView? {get}
    var emptyTitle: String {get}
    var emptyMessage: String {get}
    func showEmptyViewController(_ show: Bool)
}

extension EmptyViewable where Self: UIViewController {
    
    func showEmptyViewController(_ show: Bool) {
        if show {
            
            if childViewControllers.filter({$0 is EmptyViewController}).count == 0 {
                
                guard let emptyCtr = R.storyboard.emptyViewController.emptyViewController() else {
                    return
                }
                
                emptyCtr.view.frame = view.bounds
                emptyCtr.messageTitle = emptyTitle
                emptyCtr.message = emptyMessage
                
                if let belowView = emptyViewInsertBelowView {
                    view.insertSubview(emptyCtr.view, belowSubview: belowView)
                } else {
                    view.addSubview(emptyCtr.view)
                }
                
                addChildViewController(emptyCtr)
                emptyCtr.didMove(toParentViewController: self)
            }
            
        } else {
            
            if let ctr = childViewControllers.filter({$0 is EmptyViewController}).first {
                ctr.view.removeFromSuperview()
                ctr.removeFromParentViewController()
                ctr.didMove(toParentViewController: nil)
            }
        }
    }
}

class EmptyViewController: UIViewController {
    typealias EmptyViewAddClosure = () -> Void
    
    @IBOutlet weak var messageTitleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    var message: String = "" {
        didSet {
            if isViewLoaded {
                messageLabel.text = message
            }
        }
    }
    
    var messageTitle: String = "" {
        didSet {
            if isViewLoaded {
                messageTitleLabel.text = messageTitle
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messageLabel.text = message
        messageTitleLabel.text = messageTitle
    }
}
