//
//  KeyedDecodingContainer.swift
//  Ribbon 🎀
//
//  Created by Chris Zielinski on 7/26/19.
//  Copyright © 2019 Big Z Labs. All rights reserved.
//

extension KeyedDecodingContainer {

    // MARK: - Decoding Methods

    func decode<T: Decodable>(_ key: KeyedDecodingContainer<K>.Key) throws -> T {
        return try decode(T.self, forKey: key)
    }

    func decodeIfPresent<T: Decodable>(_ key: KeyedDecodingContainer<K>.Key) throws -> T? {
        return try decodeIfPresent(T.self, forKey: key)
    }

}
