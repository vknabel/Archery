import Foundation
import PathKit

public struct Archery {
    private let archerfileName: String

    public init(archerfileName: String = "Archerfile") {
        self.archerfileName = archerfileName
    }

    public func loadArcherfile(from path: Path? = nil) throws -> Archerfile {
        do {
            let archerfileContents = try (path ?? Path(archerfileName)).read() as String
            var plainArcherfile = try Archerfile(string: archerfileContents)
            try applyAllArcherfileLoaders(&plainArcherfile)
            return plainArcherfile
        } catch let error as NSError
            where error.domain == NSCocoaErrorDomain
            && error.code == NSFileReadNoSuchFileError {
            throw ArcheryError.noArcherfileFound
        }
    }

    public func executeScript(
        named name: String,
        using archerfile: Archerfile? = nil,
        with arguments: [String] = []
    ) throws {
        let archerfile = try loadArcherfile(archerfile, with: arguments)
        guard let script = archerfile.scripts[name]?.labeled(by: [name]) else {
            throw ArcheryError.undefinedScript(name)
        }
        return try execute(
            script: script,
            using: archerfile,
            with: arguments
        )
    }

    private func execute(script: LabeledScript, using archerfile: Archerfile, with arguments: [String] = []) throws {
        try ExecutionContext()
            .run(script, using: archerfile, with: arguments)
    }

    private func applyAllArcherfileLoaders(_ archerfile: inout Archerfile) throws {
        for i in 0... {
            guard let loader = archerfile.removeFirstLoader() else {
                return
            }
            try applyArcherfileLoader(loader.labeled(by: ["loaders", "\(i)"]), using: &archerfile)
        }
    }

    private func applyArcherfileLoader(_ loader: LabeledScript, using archerfile: inout Archerfile) throws {
        try ExecutionContext(silent: true)
            .load(loader, into: &archerfile)
    }

    private func loadArcherfile(_ archerfile: Archerfile?, with _: [String]) throws -> Archerfile {
        if let archerfile = archerfile {
            return archerfile
        } else {
            return try loadArcherfile(from: Path(archerfileName))
        }
    }
}

private func prepareMetadata<T: Encodable>(_ metadata: T) throws -> String {
    let encoder = JSONEncoder()
    let wrappedData = try encoder.encode(metadata)
    guard let wrapped = String(data: wrappedData, encoding: .utf8) else {
        throw ArcheryError.couldNotPrepareMetadata
    }
    return wrapped.replacingOccurrences(of: "\\/", with: "/")
}
