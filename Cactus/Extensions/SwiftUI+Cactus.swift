//
//  SwiftUI+Cactus.swift
//  Cactus
//
//  Created by Neil Poulin on 8/7/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import Foundation
import SwiftUI

extension View {

     /// Set the background color using a value from `NamedColor` enum
     ///   - Parameter named: The name of the color
    func background(named color: NamedColor) -> some View {
        return background(color.color.edgesIgnoringSafeArea(.all))
    }
    
    func foregroundColor(named color: NamedColor) -> some View {
        return foregroundColor(color.color)
    }
    
    func font(_ uiFont: UIFont) -> some View {
        return font(uiFont.font)
    }
    
    func font(weight: FontName = .normal, size: FontSize = .normal) -> some View {        
        return font(UIFont.init(name: weight, size: size))
    }
}


extension Text {
    func kerning(_ value: Kerning) -> Text {
        return kerning(value.rawValue)
    }
}
