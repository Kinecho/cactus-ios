//
//  PrimaryButton.swift
//  Cactus
//
//  Created by Neil Poulin on 10/7/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import UIKit

@IBDesignable
class PrimaryButton: UIButton {
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
    
    var border: CAShapeLayer?
    @IBInspectable var thickness: CGFloat = 4
    @IBInspectable var imageWidth: CGFloat = 25
    @IBInspectable var imageHeight: CGFloat = 25
    @IBInspectable var fontSize: CGFloat = 18
    @IBInspectable var horizontalPadding: CGFloat = 20
    @IBInspectable var verticalPadding: CGFloat = 12
    @IBInspectable var showBorder: Bool = true
    @IBInspectable var roundedCorners: Bool = true
    
    var borderColor: UIColor = CactusColor.darkGreen
    
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
        self.backgroundColor = CactusColor.green
        if self.isEnabled == false {
            self.backgroundColor = CactusColor.gray
        }
        
        self.setTitleColor(CactusColor.textWhite, for: .normal)
        self.titleLabel?.font = CactusFont.normal(self.fontSize)
        
        self.layoutSubviews()
        if let imageView = self.imageView {
            imageView.tintColor = CactusColor.textWhite
            self.bringSubviewToFront(imageView)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //           self.layer.borderColor = self.borderColor?.cgColor
        let radius = self.roundedCorners ? self.frame.height / 2 : CGFloat.zero
        self.layer.cornerRadius = radius
        if let imageView = self.imageView {
            imageView.contentMode = .scaleAspectFit
            imageView.bounds.size.width = imageWidth
            imageView.bounds.size.height = imageHeight
        }
        
        if self.showBorder {
            self.setupBorder()
        } else {
            self.border?.removeFromSuperlayer()
            self.border = nil
        }
    }
    
    func setupBorder() {
        let radius = self.roundedCorners ? self.frame.height / 2 : CGFloat.zero
        let path = UIBezierPath(roundedRect: self.bounds, cornerRadius: radius)
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask

        if self.border == nil {
            let border = CAShapeLayer()
            self.border = border
            self.layer.addSublayer(border)
        }
        
        if let border = self.border {
            
            let offset = thickness / 2
            border.frame = CGRect(-offset, -offset, self.bounds.width + (2 * offset), self.bounds.height)
            let pathsUsingCorrentInsetIfAny = UIBezierPath(roundedRect: border.bounds, byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: radius, height: radius))
            
            border.path = pathsUsingCorrentInsetIfAny.cgPath
            border.fillColor = UIColor.clear.cgColor
            border.strokeColor = self.borderColor.cgColor
            border.lineWidth = thickness
            var left = self.horizontalPadding
            if self.imageView?.image != nil {
                left -= self.imageWidth / 2
            }
            
            self.contentEdgeInsets = UIEdgeInsets(top: self.verticalPadding - offset, left: left, bottom: self.verticalPadding, right: self.horizontalPadding)
            self.border = border
        }
    }
}
