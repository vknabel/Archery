import struct Foundation.Data
import Unbox

public struct Archerfile: Unboxable {
    public let scripts: [String: Script]
    public let metadata: UnboxableDictionary

    public init(unboxer: Unboxer) throws {
        metadata = unboxer.dictionary
        let scriptDictionaries: [String: Any]
        if metadata["scripts"] == nil {
            scriptDictionaries = [:]
        } else {
            scriptDictionaries = try unboxer.unbox(key: "scripts")
        }
        scripts = try scriptDictionaries.mapValues { value in
            if let value = value as? String {
                return Script(arrow: value)
            } else if let value = value as? [String: Any] {
                return try Script(unboxer: Unboxer(dictionary: value))
            } else {
                throw ArcheryError.invalidScriptDefinition(value)
            }
        }
    }
}

public extension Archerfile {
    public init(metadata: UnboxableDictionary) throws {
        try self.init(unboxer: Unboxer(dictionary: metadata))
    }

    public init(data: Data) throws {
        try self.init(unboxer: Unboxer(data: data))
    }
}
