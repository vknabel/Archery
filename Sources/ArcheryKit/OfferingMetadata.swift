import Foundation
import Yams

public protocol OfferingMetadata: Codable {
    var metadata: Metadata { get }
}

public extension OfferingMetadata {
    init(metadata: Metadata) throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        let wrappedMetadata = RootElementWrapper(value: metadata)
        let encodedWrapper = try encoder.encode(wrappedMetadata)
        let wrappedElement = try decoder.decode(RootElementWrapper<Self>.self, from: encodedWrapper)
        self = wrappedElement.value
    }
}

public extension OfferingMetadata {
    init(string: String) throws {
        self = try Yams.YAMLDecoder().decode(Self.self, from: string)
    }
}

private struct RootElementWrapper<Primitive: Codable>: Codable {
    var value: Primitive
}
