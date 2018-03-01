//
//  AppUtils.swift
//  DSPSwift
//
//  Created by Daisy Ramos on 2/2/18.
//  Copyright © 2018 Daisy. All rights reserved.
//

import UIKit

extension String {
    func drawVerticallyCentered(in rect: CGRect, withAttributes attributes: [NSAttributedStringKey : Any]? = nil) {
        let size = self.size(withAttributes: attributes)
        let centeredRect = CGRect(x: rect.size.width/2, y: rect.origin.y + size.height, width: rect.size.width, height: size.height)
        self.draw(in: centeredRect, withAttributes: attributes)
    }
}
