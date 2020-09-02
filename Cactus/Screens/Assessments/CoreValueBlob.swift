//
//  CoreValueBlob.swift
//  Cactus
//
//  Created by Neil Poulin on 8/21/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import Foundation

struct CoreValueBlob {
    let image: CactusImage
    let backgroundColor: NamedColor?
    
    init (_ image: CactusImage, _ color: NamedColor?=nil) {
        self.image = image
        self.backgroundColor = color
    }

    static func forCoreValues(_ coreValues: [String]) -> CoreValueBlob {
        let input = coreValues.joined(separator: "")
        let index = getIntegerFromStringBetween(input: input, max: CoreValueBlob.all.count)
        
        return CoreValueBlob.all[index]
    }
    
    static let all: [CoreValueBlob] = [
        CoreValueBlob(.cvBlob1),
        CoreValueBlob(.cvBlob2),
        CoreValueBlob(.cvBlob3),
        CoreValueBlob(.cvBlob4),
        CoreValueBlob(.cvBlob5),
        CoreValueBlob(.cvBlob6),
        CoreValueBlob(.cvBlob7),
        CoreValueBlob(.cvBlob8),
    ]
}
