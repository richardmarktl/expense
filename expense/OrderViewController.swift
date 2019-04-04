//
//  OrderViewController.swift
//  InVoice
//
//  Created by Georg Kitz on 21/11/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import UIKit
import RxSwift
import Horreum
import CoreData

class OrderViewController: DetailTableModelController<Order, OrderModel> {
    
    override class func controllers<T>(type: T.Type) -> (UINavigationController, T) {
        guard let nCtr = R.storyboard.itemSearch.orderNavigationViewController(), let ctr = nCtr.childViewControllers.first as? T else {
            fatalError()
        }
        return (nCtr, ctr)
    }
    
    override lazy var model: OrderModel = {
       return OrderModel(item: item, in: context)
    }()
    
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var bottomTotalConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        additionalHeight = 44
        tableView.contentInset = UIEdgeInsets(top: 3, left: 0, bottom: 0, right: 0)
        
        model.totalObservable.subscribe(onNext: { [unowned self](total) in
            self.totalLabel.text = total
        }).disposed(by: bag)

        title = model.title

        setupFooterAnimations()
    }
    
    private func setupFooterAnimations() {
        NotificationCenter.default.rx.notification(Notification.Name.UIKeyboardWillShow).subscribe(onNext: { [weak self] (notf) in
            
            guard let curve = notf.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? UInt,
                let duration = notf.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double,
                let endFrame = notf.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect else {
                    return
            }
            
            self?.bottomTotalConstraint.constant = endFrame.height
            UIView.animate(withDuration: duration, delay: 0.0, options: UIViewAnimationOptions(rawValue: curve), animations: {
                self?.view.layoutIfNeeded()
            })
            
        }).disposed(by: bag)
        
        NotificationCenter.default.rx.notification(Notification.Name.UIKeyboardWillHide).subscribe(onNext: { [weak self](notf) in
            guard let curve = notf.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? UInt,
                let duration = notf.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double else {
                    return
            }
            
            self?.bottomTotalConstraint.constant = 0
            UIView.animate(withDuration: duration, delay: 0.0, options: UIViewAnimationOptions(rawValue: curve), animations: {
                self?.view.layoutIfNeeded()
            })
        }).disposed(by: bag)
    }
}
