//
//  UIStackViewExtensionis.swift
//  Cactus
//
//  Created by Neil Poulin on 12/19/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import Foundation
import UIKit

extension UIStackView {
    func addBackground(color: UIColor, cornerRadius: CGFloat?) {
        let subView = UIView(frame: bounds)
        subView.backgroundColor = color
        if let cornerRadius = cornerRadius {
            subView.layer.cornerRadius = cornerRadius
        }
        subView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        insertSubview(subView, at: 0)
    }
}
