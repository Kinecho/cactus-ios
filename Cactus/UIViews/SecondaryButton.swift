//
//  PrimaryButton.swift
//  Cactus
//
//  Created by Neil Poulin on 10/7/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import UIKit

@IBDesignable
class SecondaryButton: UIButton {
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
        
        @IBInspectable var thickness: CGFloat = 0
        @IBInspectable var imageWidth: CGFloat = 25
        @IBInspectable var imageHeight: CGFloat = 25
        @IBInspectable var fontSize: CGFloat = 17
        @IBInspectable var horizontalPadding: CGFloat = 20
        @IBInspectable var verticalPadding: CGFloat = 12
        @IBInspectable var borderColor: UIColor = CactusColor.lightBlue
        @IBInspectable var showBorder: Bool = false
        @IBInspectable var textColor: UIColor = CactusColor.textDefault
    
        @IBInspectable var borderRadius: CGFloat {
            get {
                return self.layer.cornerRadius
            }
            set {
                self.layer.cornerRadius = newValue
            }
        }
        
        func setEnabled(_ enabled: Bool) {
            if enabled == true {
    //            self.borderColor = CactusColor.white
                self.backgroundColor = CactusColor.secondaryButtonBackground
            } else {
    //            self.borderColor = CactusColor.lightGray
                self.backgroundColor = CactusColor.lightGray
            }
            
            self.isEnabled = enabled
        }
        
        func sharedInit() {
            self.clipsToBounds = true
            self.backgroundColor = CactusColor.secondaryButtonBackground
            if self.isEnabled == false {
                self.backgroundColor = CactusColor.gray
            }
            
            self.setTitleColor(.white, for: .normal)
            self.titleLabel?.font = CactusFont.normal(self.fontSize)
            self.setTitleColor(self.textColor, for: .normal)
            self.setTitleColor(CactusColor.darkText, for: .disabled)
            self.imageView?.tintColor = CactusColor.textDefault
            
            self.layoutSubviews()
            if let imageView = self.imageView {
                self.bringSubviewToFront(imageView)
            }
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            //           self.layer.borderColor = self.borderColor?.cgColor
            let radius = self.frame.height / 2
            self.layer.cornerRadius = radius
            if let imageView = self.imageView {
                imageView.contentMode = .scaleAspectFit
                imageView.bounds.size.width = imageWidth
                imageView.bounds.size.height = imageHeight
            }
            self.contentEdgeInsets = UIEdgeInsets(top: self.verticalPadding, left: self.horizontalPadding, bottom: self.verticalPadding, right: self.horizontalPadding)
            if self.showBorder {
                self.layer.borderColor = self.borderColor.cgColor
                self.layer.borderWidth = self.thickness
            } else {
                self.layer.borderWidth = 0
                self.layer.borderColor = UIColor.clear.cgColor
            }
        }
}
