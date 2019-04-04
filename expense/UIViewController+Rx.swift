//
//  UIViewController+Rx.swift
//  InVoice
//
//  Created by Richard Marktl on 05.03.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import UIKit

extension Reactive where Base: UIViewController {

    /// Reactive wrapper for the `viewWillAppear` event.
    public var viewWillAppear: Observable<[Any]> {
        return sentMessage(#selector(UIViewController.viewWillAppear(_:))).takeUntil(deallocated)
    }
    
    /// Reactive wrapper for the `viewWillAppear` event.
    public var viewDidAppear: Observable<[Any]> {
        return sentMessage(#selector(UIViewController.viewDidAppear(_:))).takeUntil(deallocated)
    }
    
    /// Reactive wrapper for the `viewWillAppear` event.
    public var viewWillDisappear: Observable<[Any]> {
        return sentMessage(#selector(UIViewController.viewWillDisappear(_:))).takeUntil(deallocated)
    }
    
    /// Reactive wrapper for the `viewWillAppear` event.
    public var viewDidDisappear: Observable<[Any]> {
        return sentMessage(#selector(UIViewController.viewDidDisappear(_:))).takeUntil(deallocated)
    }
}
