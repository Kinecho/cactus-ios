//
//  CircleImageView.swift
//  Cactus
//
//  Created by Neil Poulin on 1/15/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import UIKit

class CircleImageView: UIImageView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = max(self.bounds.width, self.bounds.height)/2
    }

}
