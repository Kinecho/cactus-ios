//
//  CircleImage.swift
//  Cactus
//
//  Created by Neil Poulin on 11/11/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import UIKit

@IBDesignable
class CircleView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.sharedInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.sharedInit()
    }
    
    override func prepareForInterfaceBuilder() {
        self.sharedInit()
    }
    
    func sharedInit() {
        self.clipsToBounds = true
        self.translatesAutoresizingMaskIntoConstraints = false
        self.widthAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        self.layer.cornerRadius = self.frame.height/2
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }

}
