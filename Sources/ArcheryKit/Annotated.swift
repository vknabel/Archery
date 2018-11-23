//
//  Annotated.swift
//  Archery
//
//  Created by Valentin Knabel on 21.11.18.
//

import Foundation

public struct Annotated<V: Codable>: Codable {
    public private(set) var metadata: Metadata
    public private(set) var value: V

    public init(value: V, by metadata: Metadata) {
        self.value = value
        self.metadata = metadata
    }

    public init(from decoder: Decoder) throws {
        metadata = try .init(from: decoder)
        value = try .init(from: decoder)
    }

    public init(metadata: Metadata) throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        let intermediate = try encoder.encode([metadata])
        let decodedArrays = try decoder.decode([Annotated<V>].self, from: intermediate)
        assert(decodedArrays.count == 1, "Put metadata into an array of size 1 to have a valid root element. Though the result doesn't contain 1 element.")
        self = decodedArrays[0]
    }

    public func encode(to encoder: Encoder) throws {
        try metadata.encode(to: encoder)
        try value.encode(to: encoder)
    }
}
