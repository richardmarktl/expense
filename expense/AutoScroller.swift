//
//  AutoScroller.swift
//  InVoice
//
//  Created by Georg Kitz on 08/06/16.
//  Copyright © 2016 meisterwork GmbH. All rights reserved.
//
import UIKit
import RxSwift
import RxCocoa

protocol AutoScroller: class {
    var scrollViewDefaultInsets: UIEdgeInsets {get set}
    var additionalHeight: CGFloat {get set}
    weak var scrollView: UIScrollView! {get set}
    func registerForKeyboardEvents(_ unregisterSignal: Observable<Void>)
}

extension AutoScroller where Self: UIViewController {
    
    func registerForKeyboardEvents(_ unregisterSignal: Observable<Void>) {
        
        let notificationCenter = NotificationCenter.default
        _ = notificationCenter.rx.notification(NSNotification.Name.UIKeyboardWillShow, object: nil).takeUntil(unregisterSignal).subscribe(onNext: { [unowned self](notification) in
            self.keyboardAppearedForNotification(notification, unregisterSignal: unregisterSignal)
        })
        
        _ = notificationCenter.rx.notification(NSNotification.Name.UIKeyboardWillChangeFrame, object: nil).takeUntil(unregisterSignal).subscribe(onNext: {(_) in
        })
        
        _ = notificationCenter.rx.notification(NSNotification.Name.UIKeyboardWillHide, object: nil).takeUntil(unregisterSignal).subscribe(onNext: { [unowned self](notification) in
            self.keyboardDisAppearedForNotification(notification)
        })
    }
    
    fileprivate func keyboardAppearedForNotification(_ notification: Notification, unregisterSignal: Observable<Void>) {
        
        guard let responder = scrollView.firstResponder() else {
            return
        }
        
        guard let userInfo = (notification as NSNotification).userInfo,
            let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let animationDuration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue else {
                return
        }
        
        //this is zero when the keyboard is already visible
        if animationDuration == 0 {
            return
        }
        
        scrollViewDefaultInsets = scrollView.contentInset
        
        var contentInset = scrollView.contentInset
        let missingHeight = calculateMissingHeight()
        contentInset.bottom = keyboardFrame.height - missingHeight
        scrollView.contentInset = contentInset
        
        let boundsChangeSignal = responder.rx.observe(CGRect.self, "bounds").takeUntil(unregisterSignal).distinctUntilChanged { $0?.height == $1?.height }.mapToVoid()
        let justObservable = Observable.just(true).mapToVoid()
        
        _ = Observable.of(boundsChangeSignal, justObservable).merge().takeUntil(unregisterSignal).subscribe(onNext: { [weak self]() in
            guard let scrollView = self?.scrollView else {
                return
            }
            
            var responderFrame = responder.convert(responder.bounds, to: scrollView)
            responderFrame = responderFrame.insetBy(dx: 0, dy: -4)
            
            if let height = self?.additionalHeight {
                responderFrame.origin.y += height
            }

            let scrollViewRect = scrollView.frame
            let visibleRect = CGRect(
                x: 0,
                y: scrollView.contentOffset.y,
                width: scrollViewRect.width,
                height: (scrollViewRect.height + missingHeight) - keyboardFrame.height // add the missing height
            )
            
            if !visibleRect.contains(responderFrame) {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1, execute: {
                    UIView.animate(withDuration: animationDuration, animations: { [weak self] in
                        self?.scrollView.scrollRectToVisible(responderFrame, animated: false)
                    })
                })
            }
        })
        
        _ = scrollView.rxDidScroll.take(1).subscribe(onNext: { _ in
            responder.resignFirstResponder()
        })
    }
    
    /// This method calculates the missing height from the max y value of the scrollview to the window
    /// bottom to ensure if the table is somewhere embedded that the scroll inset is set to the right amount.
    ///
    /// - Returns: the missing height
    fileprivate func calculateMissingHeight() -> CGFloat {
        if let superview = scrollView.superview {
            return superview.frame.height - scrollView.frame.height
        }
        return 0
    }
    
    fileprivate func keyboardDisAppearedForNotification(_ notification: Notification) {
        scrollView.contentInset = scrollViewDefaultInsets
    }
}

extension UIView {
    
    func firstResponder() -> UIView? {
        if isFirstResponder {
            return self
        }
        
        for view in subviews {
            
            if let responder = view.firstResponder() {
                return responder
            }
        }
        
        return nil
    }
}

extension UIScrollView {
    public var rxDidScroll: Observable<[Any]> {
        return rx.delegate.methodInvoked(#selector(UIScrollViewDelegate.scrollViewWillBeginDragging(_:)))
    }
}
