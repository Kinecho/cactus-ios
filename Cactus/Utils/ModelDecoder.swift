//
//  EncodingUtil.swift
//  Cactus
//
//  Created by Neil Poulin on 3/4/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import Foundation

enum ModelDecoderError: Error {
    case invalidContainer
}

class ModelDecoder<T: CodingKey> {
    var decoder: Decoder
    var container: KeyedDecodingContainer<T>
    
    init(decoder: Decoder, container: KeyedDecodingContainer<T>) {
        self.decoder = decoder
        self.container = container
        
    }
    
    static func create<T: CodingKey>(decoder: Decoder, codingKeys: T.Type) throws -> ModelDecoder<T> {
        guard let container = try? decoder.container(keyedBy: T.self)  else {
            throw ModelDecoderError.invalidContainer
        }
        
        return ModelDecoder<T>(decoder: decoder, container: container)
    }
    
    func optionalString(_ key: T, blankAsNil: Bool=false) -> String? {
        let text = try? self.container.decode(String.self, forKey: key)
        return blankAsNil && isBlank(text) ? nil : text
    }
    
    func optionalBool(_ key: T) -> Bool? {
        let value = try? self.container.decode(Bool.self, forKey: key)
        return value
    }
    
    func optionalInt(_ key: T) -> Int? {
        let value = try? self.container.decode(Int.self, forKey: key)
        return value
    }
    
    func subscriptionTierArray(_ key: T) -> [SubscriptionTier] {
        let value = try? container.decode([SubscriptionTier].self, forKey: key)
        return value ?? []
    }
    
    func optionalSubscriptionTierArray(_ key: T) -> [SubscriptionTier]? {
        let value = try? container.decode([SubscriptionTier].self, forKey: key)
        return value
    }
    
    func bool(_ key: T, default defaultValue: Bool) -> Bool {
        let value = try? self.container.decode(Bool.self, forKey: key)
        return value ?? defaultValue
    }
    
}
