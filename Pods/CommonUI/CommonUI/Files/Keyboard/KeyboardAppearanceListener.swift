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
import RxOptional

public enum AppearanceType {
    case showing
    case hiding
}

public struct KeyboardAppearance {
    public let startFrame: CGRect
    public let endFrame: CGRect
    public let animationDuration: Double
    public let type: AppearanceType
}

public protocol KeyboardAppearanceListener: class {
    func registerForKeyboardEvents(_ unregisterSignal: Observable<Void>) -> Observable<KeyboardAppearance>
}

public extension KeyboardAppearanceListener where Self: UIViewController {
    
    func registerForKeyboardEvents(_ unregisterSignal: Observable<Void>) -> Observable<KeyboardAppearance> {
        
        let notificationCenter = NotificationCenter.default
        return Observable.of(notificationCenter.rx.notification(UIResponder.keyboardWillShowNotification, object: nil),
                      notificationCenter.rx.notification(UIResponder.keyboardWillChangeFrameNotification, object: nil),
                      notificationCenter.rx.notification(UIResponder.keyboardWillHideNotification, object: nil)
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
            let keyboardEndFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let keyboardStartFrame = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue,
            let animationDuration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue else {
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
