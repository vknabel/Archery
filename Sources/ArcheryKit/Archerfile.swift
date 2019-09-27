import Foundation

public struct Archerfile: Codable, OfferingMetadata {
    public var metadata: Metadata
    public var loaders: [Script] {
        didSet { overrideMetadata() }
    }

    public var scripts: [String: Script] {
        didSet { overrideMetadata() }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Properties.self)
        loaders = try container.decodeIfPresent([Script].self, forKey: .loaders) ?? []
        scripts = try container.decodeIfPresent([String: Script].self, forKey: .scripts) ?? [:]
        metadata = try .init(from: decoder)
        overrideMetadata()
    }

    public func encode(to encoder: Encoder) throws {
        try metadata.encode(to: encoder)
    }

    private mutating func overrideMetadata() {
        metadata = metadata.replacing(using: Metadata(json: [
            "loaders": loaders.map { $0.metadata } as Any,
            "scripts": scripts.mapValues { $0.metadata } as Any,
        ]))
    }

    private enum Properties: String, CodingKey {
        case loaders, scripts
    }
}

extension Archerfile {
    mutating func removeFirstLoader() -> Script? {
        guard !loaders.isEmpty else { return nil }
        return loaders.removeFirst()
    }

    mutating func loading(additions: Metadata) throws {
        self = try Archerfile(metadata: metadata.appending(using: additions))
    }
}
