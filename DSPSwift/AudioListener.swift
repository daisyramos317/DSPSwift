//
//  AudioListener.swift
//  DSPSwift
//
//  Created by Daisy Ramos on 2/10/18.
//  Copyright © 2018 Daisy. All rights reserved.
//

import AVFoundation
import UIKit

class AudioListener: NSObject {
   
    static let `default` = AudioListener()
    var audioEngine: AVAudioEngine!
    var audioInputNode : AVAudioInputNode!
    var audioBuffer: AVAudioPCMBuffer!
    var sessionActive = false
    
    override init(){
        super.init()
        startAudioSession()
        if sessionActive {
            installTap()
        }
    }
    
    private func installTap(){
        audioEngine = AVAudioEngine()
        audioInputNode = audioEngine.inputNode
        
        /// Sample Rate
        let frameLength = UInt32(2048)
        audioBuffer = AVAudioPCMBuffer(pcmFormat: audioInputNode.outputFormat(forBus: 0), frameCapacity: frameLength)
        audioBuffer.frameLength = frameLength
        
        audioInputNode.installTap(onBus: 0, bufferSize: frameLength, format: audioInputNode.outputFormat(forBus: 0), block: { (buffer, time) in
            
            /// We're only given 1 channel, so we need to exract that data into a normalized format
            let channels = UnsafeBufferPointer(start: buffer.floatChannelData, count: Int(buffer.format.channelCount))
            let floats = [Float](UnsafeBufferPointer(start: channels[0], count: Int(buffer.frameLength)))
            for i in 0..<Int(self.audioBuffer.frameLength) {
                self.audioBuffer.floatChannelData?.pointee[i] = floats[i]
            }
        })
        try! audioEngine.start()
    }
    private func startAudioSession(){
        let audioSession = AVAudioSession.sharedInstance()
        let preferredSampleRate = 44100.0 /// Targeted default hardware rate
        let preferredIOBufferDuration = 0.02 /// 1024 / 44100 = 0.02
        
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord,
                                         mode: AVAudioSessionModeMeasurement,
                                         options: [])
           try audioSession.setPreferredSampleRate(preferredSampleRate)
           try audioSession.setPreferredIOBufferDuration(preferredIOBufferDuration)
           try audioSession.setActive(true)
           sessionActive = true
        } catch let error as NSError {
            print("Audio session error: \(error)")
        }
    }
    
    func makeSpectrumFromAudio(_ audioObject: AVAudioPCMBuffer) {
        
        guard let buffer = audioBuffer else { return }
        /// minx and maxx for scale
        var minx : Float =  1.0e12
        var maxx : Float = -1.0e12
        let fft = FFT()
        var magnitudeArray = fft.fft(buffer)
     
        for i in 0 ..< spectrumWidth {
            if i < magnitudeArray.count {
                var x = (1024.0 + 64.0 * Float(i)) * magnitudeArray[i]
                if x > maxx { maxx = x }
                if x < minx { minx = x }
                var y : Float = 0.0
                if (x > minx) {
                    if (x < 1.0) { x = 1.0 }
                    let r = (logf(maxx - minx) - logf(1.0)) * 1.0
                    let u = (logf(x    - minx) - logf(1.0))
                    y = u / r
                }
                spectrumArray[i] = y
            }
        }
    }
    
    func stopAudioEngine(){
        audioEngine.inputNode.removeTap(onBus: 0)
        audioEngine.stop()
    }
}
