//
//  UIAlertControllerExtensions.swift
//  Cactus Stage
//
//  Created by Neil Poulin on 10/24/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import Foundation
import UIKit

extension UIAlertController {

    @objc func textDidChangeInEmailConfirmAlert() {
        if let email = textFields?[0].text,
            let action = actions.last {
            action.isEnabled = isValidEmail(email)
        }
    }
}
