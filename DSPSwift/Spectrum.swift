//
//  Spectrum.swift
//  DSPSwift
//
//  Created by Daisy Ramos on 2/5/18.
//  Copyright © 2018 Daisy. All rights reserved.
//

import UIKit

let spectrumWidth  = 1024

var spectrumArray = [Float](repeating: 0, count: spectrumWidth)

class Spectrum: UIView {
    
    var labelView: UILabel!
    var slowSpectralArray = [Float](repeating: 0.0, count: spectrumWidth)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initializeViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initializeViews() {
        self.labelView = UILabel(frame: CGRect.zero)
        self.labelView.text = "FFT Frequency Spectrum"
        self.labelView.font = UIFont.systemFont(ofSize: 12.0)
        self.addSubview(self.labelView)
    }
    
    override func draw(_ rect: CGRect) {
        let context : CGContext! = UIGraphicsGetCurrentContext()
        let r0 : CGRect! = self.bounds
        if true {
            context.setFillColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            context.fill(r0)
            labelView.textColor.set()
            labelView.text?.drawVerticallyCentered(in: r0, withAttributes: [NSAttributedStringKey.font : labelView.font])
        }
        
        /// UI implementation taken from https://github.com/hotpaw2
        let r : Float = 0.25
        for i in 0 ..< spectrumWidth {
            slowSpectralArray[i] = r * spectrumArray[i] + (1.0 - r) * slowSpectralArray[i]
        }
        
        context.setFillColor(red: 0.2, green: 0.2, blue: 1.0, alpha: 1.0)
        let h0 = CGFloat(r0.size.height)
        let dx = (r0.size.width) / CGFloat(spectrumWidth)
        if spectrumArray.count >= spectrumWidth {
            for i in 0 ..< spectrumWidth  {
                let y = h0 * CGFloat(1.0 - slowSpectralArray[i])
                let x = r0.origin.x + CGFloat(i) * dx
                let h = h0 - y
                let w = dx
                let r1  = CGRect(x: x, y: y, width: w, height: h)
                context.fill(r1)
            }
        }
    }
}
