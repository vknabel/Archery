import Foundation

public typealias Archerfile = Annotated<ArcherfileConvenienceData>

public struct ArcherfileConvenienceData: Codable {
    public let scripts: [String: Script]
    public var loaders: [Loader]
}

public extension ArcherfileConvenienceData {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ArcherfileCodingKey.self)
        if container.contains(.scripts) {
            scripts = try container.decode([String: Script].self, forKey: .scripts)
        } else {
            scripts = [:]
        }
        if container.contains(.loaders) {
            loaders = try container.decode([Loader].self, forKey: .loaders)
        } else {
            loaders = []
        }
    }

    private enum ArcherfileCodingKey: String, CodingKey {
        case scripts, loaders
    }
}

extension Annotated where V == ArcherfileConvenienceData {
    internal func loading(_ additions: Metadata) throws -> Archerfile {
        return try Archerfile(metadata: metadata.overriding(using: additions))
    }

    public init(metadata: Metadata) throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        let archerfile = try decoder.decode(V.self, from: encoder.encode(metadata))
        self.init(value: archerfile, by: metadata)
    }
}

import Yams

public extension Annotated where V == ArcherfileConvenienceData {
    public init(string: String) throws {
        self = try Yams.YAMLDecoder().decode(Archerfile.self, from: string)
    }

    public var scripts: [String: Script] {
        return value.scripts
    }

    public var loaders: [Loader] {
        return value.loaders
    }

    internal func dropFirstLoader() -> Annotated {
        let newLoaders = Array(loaders.dropFirst())
        let newMetadata: Metadata
        if case var .dictionary(dict) = metadata, case let .array(metaLoaders)? = dict["loaders"] {
            dict["loaders"] = .array(Array(metaLoaders.dropFirst()))
            newMetadata = .dictionary(dict)
        } else {
            newMetadata = metadata
        }
        let newArcherfile = ArcherfileConvenienceData(
            scripts: value.scripts,
            loaders: newLoaders
        )
        return Annotated(value: newArcherfile, by: newMetadata)
    }
}
