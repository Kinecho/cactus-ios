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
}
