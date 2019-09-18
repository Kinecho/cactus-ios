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
}
