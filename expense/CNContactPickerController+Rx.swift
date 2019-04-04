//
//  CNContactPickerController+Rx.swift
//  InVoice
//
//  Created by Georg Kitz on 17/11/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import Foundation
import ContactsUI
import RxSwift
import RxCocoa
import UIKit

class ContactWrapperDelegate: NSObject, CNContactPickerDelegate {
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
    }
}

extension CNContactPickerViewController: HasDelegate {
    public typealias Delegate = CNContactPickerDelegate
}

/// For more information take a look at `DelegateProxyType`.
open class RxContactPickerControllerDelegateProxy: DelegateProxy<CNContactPickerViewController, CNContactPickerDelegate>, DelegateProxyType, CNContactPickerDelegate {
    
    /// Typed parent object.
    public weak private(set) var contactController: CNContactPickerViewController?
    
    /// - parameter navigationController: Parent object for delegate proxy.
    public init(contactController: ParentObject) {
        self.contactController = contactController
        super.init(parentObject: contactController, delegateProxy: RxContactPickerControllerDelegateProxy.self)
    }
    
    // Register known implementations
    public static func registerKnownImplementations() {
        self.register { RxContactPickerControllerDelegateProxy(contactController: $0) }
    }
}

extension Reactive where Base: CNContactPickerViewController {
    
    public var delegate: DelegateProxy<CNContactPickerViewController, CNContactPickerDelegate> {
        return RxContactPickerControllerDelegateProxy.proxy(for: base)
    }
    
    /**
     Reactive wrapper for `delegate` message.
     */
    public var didSelect: Observable<CNContact> {
        
        return delegate
            .methodInvoked(#selector(ContactWrapperDelegate.contactPicker(_:didSelect:)))
            .map({ (contact) in
                return try castOrThrow(CNContact.self, contact[1])
            })
    }
    
    /**
     Reactive wrapper for `delegate` message.
     */
    public var didCancel: Observable<()> {
        return delegate
            .methodInvoked(#selector(CNContactPickerDelegate.contactPickerDidCancel(_:)))
            .map {_ in () }
    }
    
}

/// Copied from RxCocoa because swift is not smart enough to find this function.
///
/// - Parameters:
///   - resultType:
///   - object:
/// - Returns:
/// - Throws:
private func castOrThrow<T>(_ resultType: T.Type, _ object: Any) throws -> T {
    guard let returnValue = object as? T else {
        throw RxCocoaError.castingError(object: object, targetType: resultType)
    }
    
    return returnValue
}
