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

public protocol EmptyViewable {
    var storyboardName: String { get }
    var emptyViewInsertBelowView: UIView? { get }
    var emptyTitle: String { get }
    var emptyMessage: String { get }
    func showEmptyViewController(_ show: Bool)
}

public extension EmptyViewable where Self: UIViewController {
    var storyboardName: String {
        return "EmptyViewController"
    }

    func loadEmptyViewController() -> EmptyViewController? {
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "EmptyViewController")
        return controller as? EmptyViewController
    }

    func showEmptyViewController(_ show: Bool) {
        if show {
            if children.filter({ $0 is EmptyViewController }).count == 0 {
                guard let emptyCtr = loadEmptyViewController() else {
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
                addChild(emptyCtr)
                emptyCtr.didMove(toParent: self)
            }
        } else {
            if let ctr = children.filter({ $0 is EmptyViewController }).first {
                ctr.view.removeFromSuperview()
                ctr.removeFromParent()
                ctr.didMove(toParent: nil)
            }
        }
    }
}

public class EmptyViewController: UIViewController {
    public typealias EmptyViewAddClosure = () -> Void

    @IBOutlet public weak var messageTitleLabel: UILabel!
    @IBOutlet public weak var messageLabel: UILabel!

    public var message: String = "" {
        didSet {
            if isViewLoaded {
                messageLabel.text = message
            }
        }
    }

    public var messageTitle: String = "" {
        didSet {
            if isViewLoaded {
                messageTitleLabel.text = messageTitle
            }
        }
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        messageLabel.text = message
        messageTitleLabel.text = messageTitle
    }
}
