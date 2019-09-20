//
//  ViewControllerExtensions.swift
//  Cactus
//
//  Created by Neil Poulin on 9/10/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    static func loadFromNib() -> Self {
        func instantiateFromNib<T: UIViewController>() -> T {
            let bundle = Bundle(for: T.self)
            return T.init(nibName: String(describing: T.self), bundle: bundle)
        }
        
        return instantiateFromNib()
    }
}
