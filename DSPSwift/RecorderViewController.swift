//
//  RecorderViewController.swift
//  DSPSwift
//
//  Created by Daisy Ramos on 2/1/18.
//  Copyright © 2018 Daisy. All rights reserved.
//

import AVFoundation
import UIKit

class RecorderViewController: UIViewController {
    
    var spectralView: Spectrum?
    var animationTimer : CADisplayLink!
    var audioEngine: AudioListener? = nil
    var engine = AVAudioEngine()

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if var engine = audioEngine {
            if engine.audioEngine.isRunning == false {
                engine = AudioListener()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        audioEngine = AudioListener()
        spectralView = Spectrum(frame: self.view.bounds)
        self.view.addSubview(spectralView!)

        animationTimer = CADisplayLink(target: self,
                                       selector: #selector(self.updateViews) )
        animationTimer.preferredFramesPerSecond = 60
        animationTimer.add(to: RunLoop.current,
                           forMode: RunLoopMode.commonModes )

    }

    @objc func updateViews() {
        guard (audioEngine != nil) else { return }
        if AudioListener.default.audioEngine.isRunning {
         AudioListener.default.makeSpectrumFromAudio(AudioListener.default.audioBuffer)
            spectralView?.setNeedsDisplay()

        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("Memory warning")
    }
}


