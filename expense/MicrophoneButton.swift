//
//  MicrophoneButton.swift
//  InVoice
//
//  Created by Richard Marktl on 27.11.17.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import UIKit
import AVKit
import RxSwift

class MicrophoneButton: UIView {
    /// This struct contains the button defaults
    private struct Button {
        static let width: CGFloat =  62.0
        static let height: CGFloat = 62.0
    }
    
    /// This struct contains the decibel value range
    private struct Decibel {
        static let min: Float = -160.0
        static let mid: Float =  -60.0
        static let max: Float =    0.0
    }
    
    /// This struct contains the defaults used to layout and animate the wave lines.
    private struct Line {
        static let height: CGFloat =   3.0
        static let width: CGFloat =    2.0
        static let space: CGFloat =    2.0
        static let count: Int =       15
        static let phaseStep: Float = -0.15
    }
    
    private var recorder: AVAudioRecorder? = setupRecorder()
    private var microphoneImageView: UIImageView = UIImageView(image: R.image.micIcon())
    
    /// The member display link is used to get the udpateMeters calls to update the wave
    private var displayLink: CADisplayLink?
    private var amplitude: CGFloat = 0.0
    private var phase: Float = 0.0
    private let exponent = powf(10.0, 0.05 * Decibel.mid)
    private var waveViews: [UIView] = {
        var array: [UIView] = []
        let image = R.image.sound_wave_line()?.stretchableImage(withLeftCapWidth: 1, topCapHeight: 1)
        let yPos = (Button.height-Line.height)/2
        for index in 0...Line.count {
            let image = UIImageView(image: image)
            let xPos = CGFloat(index) * (Line.space + Line.width)
            image.frame = CGRect(x: xPos, y: yPos, width: Line.width, height: Line.height)
            image.alpha = 0.0
            array.append(image)
        }
        return array
    }()
    
    private var tapGesture: UITapGestureRecognizer = UITapGestureRecognizer()
    public var tapObservable: Observable<UITapGestureRecognizer> {
        return tapGesture.rx.event.asObservable()
    }

    private var silenceTracker: SilenceTracker = SilenceTracker()
    public var duration: SilenceDuration {
        get {
            return silenceTracker.duration
        }
        set {
            silenceTracker.duration = newValue
        }
    }
    public var silenceObservable: Observable<Int> {
        return silenceTracker.silenceObservable
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    private func setup() {
        displayLink =  CADisplayLink(target: self, selector: #selector(updateMeters))
        displayLink?.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
        
        // add a background view
        let background = UIView(frame: CGRect(x: 0, y: 0, width: Button.width, height: Button.height))
        background.backgroundColor = .main
        background.layer.cornerRadius = Button.height/2
        background.layer.shadowColor = UIColor.black.cgColor
        background.layer.shadowOffset = CGSize(width: 2, height: 2)
        background.layer.shadowRadius = 5
        background.layer.shadowOpacity = 0.5
        addSubview(background)
        
        // then add the wave views
        for view in waveViews {
            addSubview(view)
        }
        
        // a microphone view added above the other views
        microphoneImageView.contentMode = .center
        microphoneImageView.frame = background.frame
        addSubview(microphoneImageView)
        
        addGestureRecognizer(tapGesture)
    }
    
    /// This method is used to update the wave images views.
    @objc private func updateMeters() {
        guard let recorder = recorder, recorder.isRecording == true else {
            return
        }
        // first update the meters and then get the new power value
        recorder.updateMeters()
        
        let decibels: Float = recorder.averagePower(forChannel: 0)
        silenceTracker.checkSilence(decibels: decibels)
        amplitude = CGFloat(normalize(decibels: decibels / 1.7))  // added the factor 1.8 to get a fancier animation
        setNeedsLayout()
        setNeedsDisplay()
    }
    
    /// This method will start the recording process.
    public func record() {
        guard let recorder = recorder, recorder.isRecording == false else {
            return
        }
        
        recorder.record()
        tapGesture.isEnabled = true
        show(microphone: false)
    }
    
    /// This method will stop the recording.
    public func stop() {
        guard let recorder = recorder, recorder.isRecording == true else {
            return
        }

        recorder.stop()
        silenceTracker.stop()
        tapGesture.isEnabled = false
        show(microphone: true)
    }
    
    /// The method show will animate the microphone button appeareance.
    ///
    /// - Parameter microphone: true if to visible otherwise false
    private func show(microphone: Bool) {
        let alpha = microphone ? 1.0 : 0.0
        UIView.animate(withDuration: 0.2, animations: {
            self.microphoneImageView.alpha = CGFloat(alpha)
            self.waveViews.forEach({ (view) in
                view.alpha = CGFloat(fabs(alpha-1.0))
            })
        })
    }
    
    /// This method is used to normalize the decibel level. The output is a value between 1.0 and 0.0.
    /// The formalur is here to generate a non linare level of the function.
    /// The formular:
    /// powerOf = 10^0.05*-60 = 10^-3
    /// result = ( (10^0.05*decibel) * powerOf * (1.0 / (1.0 - powerOf)) )^0.5
    ///
    /// - Parameter decibels: The decibel value from the recorder default range ( 0 ... - 60 )
    /// - Returns: the normalized amplitude.
    private func normalize(decibels: Float) -> Float {
        if decibels < Decibel.mid || decibels == Decibel.max {
            return 0.0
        }
        return powf((powf(10.0, 0.05 * decibels) - exponent) * (1.0 / (1.0 - exponent)), 0.5)
    }
    
    override func layoutSubviews() {
         super.layoutSubviews()
        
        // to give the view a wave filing shift it
        phase += Line.phaseStep

        // thanks to Stefan Ceriu for https://github.com/stefanceriu/SCSiriWaveformView
        let maxAmplitude: CGFloat = bounds.height / 2.0
        let width: CGFloat = bounds.width
        let radius: CGFloat  = width / 2
        
        for waveView in waveViews {
            // get the center point of the view it is needed to restore the position of the waveView
            let center: CGPoint = waveView.center
            
            // We use a parable to scale the sinus wave, that has its peak in the middle of the view.
            let scaling: CGFloat = -pow(1 / radius * (center.x - radius), 2) + 1
            let sinus: CGFloat = CGFloat(sinf(2 * .pi * Float(center.x / width) * 1.5 + phase))
            let peakHeight: CGFloat = scaling * maxAmplitude * amplitude * 1.1 * sinus
            let height: CGFloat = round(fabs(peakHeight) + 0.5) * 2 + Line.height
            
            // user the calculated size to bounce the view.
            waveView.frame.size = CGSize(width: Line.width, height: min(height, round(Button.height * scaling)))
            waveView.center = center
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: Button.width, height: Button.height)
    }
    
    deinit {
        displayLink?.invalidate()
        displayLink = nil
    }
}

/// This method creates the AVAudioRecorder instance used in the microphone.
///
/// - Returns: a AVAudioRecorder instance
private func setupRecorder() -> AVAudioRecorder? {
    let url: URL = URL(fileURLWithPath: NSTemporaryDirectory().appending("sound.caf"))
    let settings: [String: Any] = [
        AVSampleRateKey: 16000.0,  // 44100.0
        AVFormatIDKey: kAudioFormatAppleLossless,
        AVNumberOfChannelsKey: 1,
        AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue
    ]
    
    do {
        let recorder = try AVAudioRecorder(url: url, settings: settings)
        recorder.prepareToRecord()
        recorder.isMeteringEnabled = true
        return recorder
    } catch {
        logger.error("failed with: \(error)")
    }
    return nil
}
