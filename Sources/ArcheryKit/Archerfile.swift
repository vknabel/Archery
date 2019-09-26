import ArcherfileDecl
import Foundation

public typealias Archerfile = ArcherfileDecl

extension Archerfile {
    mutating func removeFirstLoader() -> ScriptDecl? {
        guard let currentLoaders = loaders, !currentLoaders.isEmpty else { return nil }
        return loaders?.removeFirst()
    }

    mutating func loading(additions: Metadata) throws {
        self = try Archerfile(metadata: metadata.appending(using: additions))
    }
}
