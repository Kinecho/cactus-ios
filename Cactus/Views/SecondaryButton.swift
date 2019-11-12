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
    
    var border: CAShapeLayer?
    @IBInspectable var thickness: CGFloat = 4
    @IBInspectable var imageWidth: CGFloat = 25
    @IBInspectable var imageHeight: CGFloat = 25
    @IBInspectable var fontSize: CGFloat = 17
    @IBInspectable var horizontalPadding: CGFloat = 20
    @IBInspectable var verticalPadding: CGFloat = 12
    
//    var borderColor: UIColor = CactusColor.darkGreen
//    var mainColor: UIColor = CactusColor.green
    
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
            self.backgroundColor = CactusColor.white
        } else {
//            self.borderColor = CactusColor.lightGray
            self.backgroundColor = CactusColor.lightGray
        }
        
        self.isEnabled = enabled
    }
    
    func sharedInit() {
        self.clipsToBounds = true
        self.backgroundColor = CactusColor.white
        if self.isEnabled == false {
            self.backgroundColor = CactusColor.gray
        }
        
        self.setTitleColor(.white, for: .normal)
        self.titleLabel?.font = CactusFont.normal(self.fontSize)
        self.setTitleColor(CactusColor.darkestGreen, for: .normal)
        self.setTitleColor(CactusColor.darkText, for: .disabled)
        
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
        
//        let path = UIBezierPath(roundedRect: self.bounds, cornerRadius: radius)
//        let mask = CAShapeLayer()
//        mask.path = path.cgPath
//        self.layer.mask = mask

//        if self.border == nil {
//            let border = CAShapeLayer()
//            self.border = border
//            self.layer.addSublayer(border)
//        }
        
//        if let border = self.border {
//
//            let offset = thickness / 2
//            border.frame = CGRect(-offset, -offset, self.bounds.width + (2 * offset), self.bounds.height)
//            let pathsUsingCorrentInsetIfAny = UIBezierPath(roundedRect: border.bounds, byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: radius, height: radius))
//
//            border.path = pathsUsingCorrentInsetIfAny.cgPath
//            border.fillColor = UIColor.clear.cgColor
//            border.strokeColor = self.borderColor.cgColor
//            border.lineWidth = thickness
//            self.contentEdgeInsets = UIEdgeInsets(top: self.verticalPadding - offset, left: self.horizontalPadding, bottom: self.verticalPadding, right: self.horizontalPadding)
//            self.border = border
//        }
    }
}
