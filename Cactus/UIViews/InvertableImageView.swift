//
//  InvertableImageView.swift
//  Cactus
//
//  Created by Neil Poulin on 12/16/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import UIKit

class InvertableImageView: UIImageView {
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    let logger = Logger("InvertableImageView")
    var originalImage: UIImage?
    var invertedImage: UIImage?
    var allowInvert: Bool = true
    
    override var image: UIImage? {
        didSet {
            guard self.allowInvert else {
                return
            }
            if originalImage == nil {
                self.originalImage = self.image
            }
            super.image = image
            self.invertImageIfNeeded()
        }
    }
    
    func invertImageIfNeeded() {
        guard self.allowInvert else {
            return
        }
        
        if traitCollection.userInterfaceStyle == .dark {
            if self.invertedImage == nil {
                self.invertedImage = self.originalImage?.invertedColors()
            }
            super.image = self.invertedImage
        } else {
            super.image = originalImage
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        guard self.allowInvert else {
            return
        }
        super.traitCollectionDidChange(previousTraitCollection)
        self.invertImageIfNeeded()
    }
}
