//
//  SilenceTracker.swift
//  InVoice
//
//  Created by Richard Marktl on 30.11.17.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import Foundation
import RxSwift

/// The durations the silence tracker supports.
enum SilenceDuration: TimeInterval {
    case short = 0.25
    case medium = 1.00
    case long = 2.00
}

/// The class SilenceTracker will measure a stead stream of audio events and fire events if there was no voice input
/// for a certain amount of time.
class SilenceTracker {
    /// This member contains the last TimeInterval value since a voice was recorded
    private var silentSince: TimeInterval?

    /// This members counts a how many silenceDuration nothing was recorded
    private var firedSinceSilent: Int = 0
    
    /// This member contains duration of we need to recorded nothing until we fire an event.
    public var duration: SilenceDuration = .short
    
    private var silenceSubject = PublishSubject<Int>()
    public var silenceObservable: Observable<Int> {
        return silenceSubject.asObservable()
    }
    
    /// This method should receive an steady stream of decibels delivered from the AVAudioRecorder.
    /// - SeeAlso: AVAudioRecorder
    ///
    /// - Parameter decibels: the decibels as delivered by `AVAudioRecorder.averagePower(forChannel:)`
    public func checkSilence(decibels: Float) {
        let interval = Date().timeIntervalSince1970
        
        if decibels < -50 {
            if silentSince == nil {
                silentSince = interval
            }
        } else {
            stop()
        }
        
        let duration = self.duration.rawValue
        if let since = silentSince, (interval - since) > duration {
            if (interval - since) > (Double(firedSinceSilent + 1) * duration) {
                firedSinceSilent += 1
                silenceSubject.onNext(firedSinceSilent)
            }
        }
    }
    
    public func stop() {
        silentSince = nil
        firedSinceSilent = 0
    }
}
