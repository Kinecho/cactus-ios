//
//  ArrayExtensions.swift
//  Cactus
//
//  Created by Neil Poulin on 6/30/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import Foundation

extension Array where Element: Comparable {
    func containsSameElements(as other: [Element]) -> Bool {
        return self.count == other.count && self.sorted() == other.sorted()
    }
}
