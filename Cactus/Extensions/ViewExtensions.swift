//
//  ViewExtensions.swift
//  Cactus Stage
//
//  Created by Neil Poulin on 7/27/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func setupKeyboardDismissRecognizer() {
        let tapRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(self.dismissKeyboard))
        tapRecognizer.cancelsTouchesInView = false
        self.addGestureRecognizer(tapRecognizer)
    }
    
    @objc func dismissKeyboard() {
        self.endEditing(true)
    }
}
