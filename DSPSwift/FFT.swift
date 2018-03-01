//
//  FFT.swift
//  DSPSwift
//
//  Created by Daisy Ramos on 2/1/18.
//  Copyright © 2018 Daisy. All rights reserved.
//

import Foundation
import Accelerate
import AVFoundation

final class FFT: NSObject {

    /// - Parameter buffer: Audio data in PCM format
    func fft(_ buffer: AVAudioPCMBuffer) -> [Float] {
        
        let size: Int = Int(buffer.frameLength)
        
        /// Set up the transform
        let log2n = UInt(round(log2f(Float(size))))
        let bufferSize = Int(1 << log2n)
        
        /// Sampling rate / 2
        let inputCount = bufferSize / 2
        
        /// FFT weights arrays are created by calling vDSP_create_fftsetup (single-precision) or vDSP_create_fftsetupD (double-precision). Before calling a function that processes in the frequency domain
        let fftSetup = vDSP_create_fftsetup(log2n, Int32(kFFTRadix2))
        
        /// Create the complex split value to hold the output of the transform
        var realp = [Float](repeating: 0, count: inputCount)
        var imagp = [Float](repeating: 0, count: inputCount)
        var output = DSPSplitComplex(realp: &realp, imagp: &imagp)
        
        
        var transferBuffer = [Float](repeating: 0, count: bufferSize)
        vDSP_hann_window(&transferBuffer, vDSP_Length(bufferSize), Int32(vDSP_HANN_NORM))
        vDSP_vmul((buffer.floatChannelData?.pointee)!, 1, transferBuffer,
                  1, &transferBuffer, 1, vDSP_Length(bufferSize))
        
        let temp = UnsafePointer<Float>(transferBuffer)
        
        temp.withMemoryRebound(to: DSPComplex.self, capacity: transferBuffer.count) { (typeConvertedTransferBuffer) -> Void in
            vDSP_ctoz(typeConvertedTransferBuffer, 2, &output, 1, vDSP_Length(inputCount))
        }
        /// Do the fast Fournier forward transform
        vDSP_fft_zrip(fftSetup!, &output, 1, log2n, Int32(FFT_FORWARD))
        
        /// Convert the complex output to magnitude
        var magnitudes = [Float](repeating: 0.0, count: inputCount)
        vDSP_zvmags(&output, 1, &magnitudes, 1, vDSP_Length(inputCount))

        var normalizedMagnitudes = [Float](repeating: 0.0, count: inputCount)
        vDSP_vsmul(sqrtq(magnitudes), 1, [2.0/Float(inputCount)],
                   &normalizedMagnitudes, 1, vDSP_Length(inputCount))

        print("Normalized magnitudes: \(magnitudes)")
        
        /// Release the setup
         vDSP_destroy_fftsetup(fftSetup)
        
        return normalizedMagnitudes
        
    }
    
    func sqrtq(_ x: [Float]) -> [Float] {
        var results = [Float](repeating: 0.0, count: x.count)
        vvsqrtf(&results, x, [Int32(x.count)])
        
        return results
    }
    
}

