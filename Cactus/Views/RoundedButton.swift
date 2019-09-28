//
//  RoundedButton.swift
//  MagicBook
//
//  Created by Neil Poulin on 4/29/19.
//  Copyright © 2019 Kinecho. All rights reserved.
//

import UIKit

@IBDesignable
class RoundedButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    override func prepareForInterfaceBuilder() {
        sharedInit()
    }
    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        //        self.sharedInit()
//    }
    
    @IBInspectable var imageWidth: CGFloat = 25
    @IBInspectable var imageHeight: CGFloat = 25
    
    @IBInspectable var borderRadius: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set {
            self.layer.cornerRadius = newValue
        }
    }
    
    func sharedInit() {
        self.clipsToBounds = true
        self.titleLabel?.font = CactusFont.normal(self.titleLabel?.font.pointSize ?? 17)
        if let imageView = self.imageView {
            self.bringSubviewToFront(imageView)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let imageView = self.imageView {
            imageView.contentMode = .scaleAspectFit
            imageView.bounds.size.width = imageWidth
            imageView.bounds.size.height = imageHeight
        }
    }
    
}
