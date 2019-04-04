//
//  KeyboardAppearanceListener.swift
//  InVoice
//
//  Created by Georg Kitz on 09.08.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

enum AppearanceType {
    case showing
    case hiding
}

struct KeyboardAppearance {
    let startFrame: CGRect
    let endFrame: CGRect
    let animationDuration: Double
    let type: AppearanceType
}

protocol KeyboardAppearanceListener: class {
    func registerForKeyboardEvents(_ unregisterSignal: Observable<Void>) -> Observable<KeyboardAppearance>
}

extension KeyboardAppearanceListener where Self: UIViewController {
    
    func registerForKeyboardEvents(_ unregisterSignal: Observable<Void>) -> Observable<KeyboardAppearance> {
        
        let notificationCenter = NotificationCenter.default
        
        return Observable.of(notificationCenter.rx.notification(NSNotification.Name.UIKeyboardWillShow, object: nil),
                      notificationCenter.rx.notification(NSNotification.Name.UIKeyboardWillChangeFrame, object: nil),
                      notificationCenter.rx.notification(NSNotification.Name.UIKeyboardWillHide, object: nil)
        )
        .merge()
        .takeUntil(unregisterSignal)
        .map { [unowned self](notification) -> KeyboardAppearance? in
            return self.handleKeyboarNotification(notification)
        }
        .filterNil()
    }
    
    fileprivate func handleKeyboarNotification(_ notification: Notification) -> KeyboardAppearance? {
        
        guard let userInfo = (notification as NSNotification).userInfo,
            let keyboardEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let keyboardStartFrame = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue,
            let animationDuration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue else {
                return nil
        }
        
        //this is zero when the keyboard is already visible
        if animationDuration == 0 {
            return nil
        }
        let type = self.view.frame.height == keyboardEndFrame.minY ? AppearanceType.hiding : AppearanceType.showing
        return KeyboardAppearance(startFrame: keyboardStartFrame, endFrame: keyboardEndFrame, animationDuration: animationDuration, type: type)
    }
}
