//
//  ImageExtensions.swift
//  Cactus
//
//  Created by Neil Poulin on 9/17/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    func setImageFile(_ image: ImageFile?) {
        guard let image = image else {
            self.isHidden = true
            return
        }
        
        if let invertableImageView = self as? InvertableImageView {
            invertableImageView.allowInvert = image.allowDarkModeInvert ?? false
        }
        
        ImageService.shared.setPhoto(self, photo: image)
    }
    
    func withUrl(_ url: String) {
        ImageService.shared.setFromUrl(self, url: url)
    }
}

extension UIImage {
    func withWidth(_ newWidth: CGFloat ) -> UIImage? {
        let image = self
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
        
    /// Inverts the colors from the current image. Black turns white, white turns black etc.
    func invertedColors() -> UIImage? {
        guard let ciImage = CIImage(image: self) ?? ciImage, let filter = CIFilter(name: "CIColorInvert") else { return nil }
        filter.setValue(ciImage, forKey: kCIInputImageKey)

        guard let outputImage = filter.outputImage else { return nil }
        return UIImage(ciImage: outputImage)
    }
}
