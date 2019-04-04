//
//  AVSpeechUtterance+Reactive.swift
//  InVoice
//
//  Created by Richard Marktl on 16.11.17.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import RxSwift
import RxCocoa
import Speech

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

// MARK: - Extension HasDelegate
extension AVSpeechSynthesizer: HasDelegate {
    public typealias Delegate = AVSpeechSynthesizerDelegate
}

/// For more information take a look at `DelegateProxyType`.
open class RxAVSpeechSynthesizerDelegateProxy: DelegateProxy<AVSpeechSynthesizer, AVSpeechSynthesizerDelegate>,
                                               DelegateProxyType, AVSpeechSynthesizerDelegate {
    
    /// Typed parent object.
    public weak private(set) var synthesizer: AVSpeechSynthesizer?
    
    /// - parameter synthesizer: Parent object for delegate proxy.
    public init(synthesizer: ParentObject) {
        self.synthesizer = synthesizer
        super.init(parentObject: synthesizer, delegateProxy: RxAVSpeechSynthesizerDelegateProxy.self)
    }
    
    // Register known implementations
    public static func registerKnownImplementations() {
        self.register { RxAVSpeechSynthesizerDelegateProxy(synthesizer: $0) }
    }
}

// MARK: - AVSpeechSynthesizer Reactive Delegate Extension
extension Reactive where Base: AVSpeechSynthesizer {
    public typealias WillSpeakRangeOfSpeechStringEvent = (characterRange: NSRange, utterance: AVSpeechUtterance)
    
    /// Reactive wrapper for `delegate`.
    ///
    /// For more information take a look at `DelegateProxyType` protocol documentation.
    public var delegate: DelegateProxy<AVSpeechSynthesizer, AVSpeechSynthesizerDelegate> {
        return RxAVSpeechSynthesizerDelegateProxy.proxy(for: base)
    }
    
    /// Reactive wrapper for delegate method `didStartSpeechUtterance`
    public var didStartSpeechUtterance: ControlEvent<AVSpeechUtterance> {
        let source = delegate.methodInvoked(#selector(AVSpeechSynthesizerDelegate.speechSynthesizer(_:didStart:))).map { value -> AVSpeechUtterance in
            return try castOrThrow(AVSpeechUtterance.self, value[1])
        }
        return ControlEvent(events: source)
    }
    
    /// Reactive wrapper for delegate method `didFinishSpeechUtterance`
    public var didFinishSpeechUtterance: ControlEvent<AVSpeechUtterance> {
        let source = delegate.methodInvoked(#selector(AVSpeechSynthesizerDelegate.speechSynthesizer(_:didFinish:))).map { value -> AVSpeechUtterance in
            return try castOrThrow(AVSpeechUtterance.self, value[1])
        }
        return ControlEvent(events: source)
    }
    
    /// Reactive wrapper for delegate method `didPauseSpeechUtterance`
    public var didPauseSpeechUtterance: ControlEvent<AVSpeechUtterance> {
        let source = delegate.methodInvoked(#selector(AVSpeechSynthesizerDelegate.speechSynthesizer(_:didPause:))).map { value -> AVSpeechUtterance in
            return try castOrThrow(AVSpeechUtterance.self, value[1])
        }
        return ControlEvent(events: source)
    }
    
    /// Reactive wrapper for delegate method `didContinueSpeechUtterance`
    public var didContinueSpeechUtterance: ControlEvent<AVSpeechUtterance> {
        let source = delegate.methodInvoked(#selector(AVSpeechSynthesizerDelegate.speechSynthesizer(_:didContinue:))).map { value -> AVSpeechUtterance in
            return try castOrThrow(AVSpeechUtterance.self, value[1])
        }
        return ControlEvent(events: source)
    }
    
    /// Reactive wrapper for delegate method `speechSynthesizer(_:didCancelSpeechUtterance)`
    public var didCancelSpeechUtterance: ControlEvent<AVSpeechUtterance> {
        let source = delegate.methodInvoked(#selector(AVSpeechSynthesizerDelegate.speechSynthesizer(_:didCancel:))).map { value -> AVSpeechUtterance in
            return try castOrThrow(AVSpeechUtterance.self, value[1])
        }
        return ControlEvent(events: source)
    }
    
    /// Reactive wrapper for delegate method `speechSynthesizer(_:willSpeakRangeOfSpeechString:utterance:)`
    public var willSpeakRangeOfSpeechString: ControlEvent<WillSpeakRangeOfSpeechStringEvent> {
        let source = delegate.methodInvoked(#selector(AVSpeechSynthesizerDelegate.speechSynthesizer(_:willSpeakRangeOfSpeechString:utterance:))).map { value -> WillSpeakRangeOfSpeechStringEvent in
            let characterRange = try castOrThrow(NSRange.self, value[1])
            let utterance = try castOrThrow(AVSpeechUtterance.self, value[2])

            return (characterRange, utterance)
            
        }
        return ControlEvent(events: source)
    }
    
    /// Installs delegate as forwarding delegate on `delegate`.
    /// Delegate won't be retained.
    ///
    /// It enables using normal delegate mechanism with reactive delegate mechanism.
    ///
    /// - parameter delegate: Delegate object.
    /// - returns: Disposable object that can be used to unbind the delegate.
    public func setDelegate(_ delegate: AVSpeechSynthesizerDelegate)
        -> Disposable {
            return RxAVSpeechSynthesizerDelegateProxy.installForwardDelegate(delegate, retainDelegate: false, onProxyForObject: self.base)
    }
}
