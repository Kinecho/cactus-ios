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
    @IBInspectable var thickness: CGFloat = 16
    @IBInspectable var imageWidth: CGFloat = 25
    @IBInspectable var imageHeight: CGFloat = 25
    @IBInspectable var fontSize: CGFloat = 18
    
    @IBInspectable var showBorder: Bool = true
    
    var borderColor: UIColor = CactusColor.fancyLinkHighlight
    
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
        
        self.setTitleColor(CactusColor.textDefault, for: .normal)
        self.setTitleColor(CactusColor.textMinimized, for: .disabled)
        self.titleLabel?.font = CactusFont.normal(self.fontSize)
        
        self.layoutSubviews()
        if let imageView = self.imageView {
            imageView.tintColor = CactusColor.textDefault
            self.bringSubviewToFront(imageView)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //           self.layer.borderColor = self.borderColor?.cgColor
//        let radius = self.frame.height / 2
//        self.layer.cornerRadius = radius
        if let imageView = self.imageView {
            imageView.contentMode = .scaleAspectFit
            imageView.bounds.size.width = imageWidth
            imageView.bounds.size.height = imageHeight
        }
        self.setupBorder()
    }
    
    func setupBorder() {
//        let radius = self.frame.height / 2
//        let path = UIBezierPath(roundedRect: self.bounds, cornerRadius: radius)
//        let mask = CAShapeLayer()
//        mask.path = path.cgPath
//        self.layer.mask = mask

        if self.border == nil {
            let border = CALayer()
            self.border = border
            self.layer.addSublayer(border)
        }
        
        if let border = self.border {
            border.backgroundColor = self.borderColor.cgColor
            border.opacity = 0.6
            let offset = self.thickness / 2
            let y = self.bounds.height - offset - 4
            border.frame = CGRect(x: 0, y: y, width: self.bounds.width, height: self.thickness)
//            self.layer.addSublayer(border)
            
//            let pathsUsingCorrentInsetIfAny = UIBezierPath(roundedRect: border.bounds, byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: radius, height: radius))
            
//            border.path = pathsUsingCorrentInsetIfAny.cgPath
//            border.fillColor = self.borderColor.cgColor
//            border.strokeColor = self.borderColor.cgColor
//            border.lineWidth = thickness
//            var left = self.horizontalPadding
//            if self.imageView?.image != nil {
//                left -= self.imageWidth / 2
//            }
            
//            self.contentEdgeInsets = UIEdgeInsets(top: self.verticalPadding - offset, left: left, bottom: self.verticalPadding, right: self.horizontalPadding)
            self.border = border
        }
    }
}
