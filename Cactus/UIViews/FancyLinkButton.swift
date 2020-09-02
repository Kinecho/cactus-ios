//
//  PrimaryButton.swift
//  Cactus
//
//  Created by Neil Poulin on 10/7/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import UIKit

@IBDesignable
class FancyLinkButton: UIButton {
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
    
    var border: CALayer?
    @IBInspectable var thickness: CGFloat = 10
    @IBInspectable var imageWidth: CGFloat = 25
    @IBInspectable var imageHeight: CGFloat = 25
    @IBInspectable var fontSize: CGFloat = 18
    
    @IBInspectable var showBorder: Bool = true
    
    @IBInspectable var borderColor: UIColor = CactusColor.fancyLinkHighlight
    @IBInspectable var textColorNormal: UIColor = CactusColor.textDefault {
        didSet {
            self.setTitleColor(self.textColorNormal, for: .normal)
        }
    }
    @IBInspectable var textColorDisabled: UIColor = CactusColor.gray
    
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
            self.borderColor = CactusColor.darkGreen
            self.backgroundColor = CactusColor.green
            self.showBorder = true
        } else {
            self.borderColor = CactusColor.darkGray
            self.backgroundColor = CactusColor.gray
            self.showBorder = false
        }
        
        self.isEnabled = enabled
    }
    
    func sharedInit() {
        self.clipsToBounds = true
        self.backgroundColor = .clear
        
        self.setTitleColor(self.textColorNormal, for: .normal)
        self.setTitleColor(self.textColorDisabled, for: .disabled)
        self.titleLabel?.font = CactusFont.normal(self.fontSize)
        
        self.layoutSubviews()
        if let imageView = self.imageView {
            imageView.tintColor = CactusColor.textDefault
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
        self.setupBorder()
    }
    
    func setupBorder() {
        if self.border == nil {
            let border = CALayer()
            self.border = border
            self.layer.insertSublayer(border, at: 0)
        }
        
        if let border = self.border {
            border.backgroundColor = self.borderColor.cgColor
            border.opacity = 0.5
            let offset = self.thickness / 2
            let y = self.bounds.height - offset - 8
            let xPadding: CGFloat = 2
            border.frame = CGRect(x: -1 * xPadding, y: y, width: self.bounds.width + xPadding, height: self.thickness)

            self.border = border
        }
    }
}
