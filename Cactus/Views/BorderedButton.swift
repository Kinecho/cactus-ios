//
//  BorderedButton.swift
//  Cactus
//
//  Created by Neil Poulin on 7/26/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import UIKit

@IBDesignable
class BorderedButton: UIButton {
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
                self.sharedInit()
    }
    
    @IBInspectable var imageWidth: CGFloat = 25
    @IBInspectable var imageHeight: CGFloat = 25
    
    @IBInspectable var borderColor: UIColor? {
        get {
            if self.layer.borderColor != nil {
                return UIColor.init(cgColor: self.layer.borderColor!)
            }
            return nil
        }
        set {
            self.layer.borderColor = newValue?.cgColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return self.layer.borderWidth
        }
        set {
            self.layer.borderWidth = newValue
        }
    }
    
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
        self.layoutSubviews()
        if let imageView = self.imageView {
            self.bringSubviewToFront(imageView)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.borderColor = self.borderColor?.cgColor
        self.layer.cornerRadius = self.borderRadius
        if let imageView = self.imageView {
            imageView.contentMode = .scaleAspectFit
            imageView.bounds.size.width = imageWidth
            imageView.bounds.size.height = imageHeight
        }
    }
    
}
