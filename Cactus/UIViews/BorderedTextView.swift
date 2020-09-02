//
//  CactusTextInputField.swift
//  Cactus
//
//  Created by Neil Poulin on 10/24/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import UIKit

@IBDesignable
class BorderedTextView: UITextView {

//    let padding = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
    
    @IBInspectable var cornerRadius: CGFloat = 12
    @IBInspectable var borderWidth: CGFloat = 1
    @IBInspectable var borderColor: UIColor? = CactusColor.green
    
    override func prepareForInterfaceBuilder() {
        self.setup()
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
    }
    
    func setup() {
        self.clipsToBounds = true
        self.layer.borderColor = self.borderColor?.cgColor
        self.layer.borderWidth = self.borderWidth
        self.layer.cornerRadius = self.cornerRadius
        
//        self.heightAnchor.constraint(equalToConstant: self.font?.lineHeight ?? 16 + 10).isActive = true
        
    }
    
//    override open func textRect(forBounds bounds: CGRect) -> CGRect {
//        return bounds.inset(by: padding)
//    }
//
//    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
//        return bounds.inset(by: padding)
//    }
//
//    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
//        return bounds.inset(by: padding)
//    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        self.setup()
        
    }
    
}
