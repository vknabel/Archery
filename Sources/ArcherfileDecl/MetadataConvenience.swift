import Foundation
import Yams

public protocol OfferingMetadata: Codable {
    var metadata: Metadata { get }
}

public extension OfferingMetadata {
    init(metadata: Metadata) throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        self = try decoder.decode(Self.self, from: encoder.encode(metadata))
    }
}

public extension OfferingMetadata {
    init(string: String) throws {
        self = try Yams.YAMLDecoder().decode(Self.self, from: string)
    }
}
