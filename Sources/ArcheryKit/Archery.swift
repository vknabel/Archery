import struct Foundation.Data
import Foundation.NSError
import MintKit
import PathKit
import Unbox
import Wrap

public struct Archery {
    private let archerfileName: String
    private let mint: Mint

    public init(archerfileName: String = "Archerfile", mint: Mint = Mint(path: "./.archery/mint")) {
        self.archerfileName = archerfileName
        self.mint = mint
    }

    public func loadArcherfile(from path: Path? = nil) throws -> Archerfile {
        do {
            let plainArcherfile = try unbox(data: try (path ?? Path(self.archerfileName)).read() as Data) as Archerfile
            return plainArcherfile
        } catch let error as NSError where error.domain == NSCocoaErrorDomain && error.code == NSFileReadNoSuchFileError {
            throw ArcheryError.noArcherfileFound
        }
    }

    public func executeScript(_ script: Script, using archerfile: Archerfile, with arguments: [String] = []) throws {
        try mint.run(
            package(for: script),
            arguments: [
                Archery.apiLevel,
                prepareMetadata(archerfile.metadata),
                prepareMetadata(script.metadata),
            ] + arguments,
            verbose: arguments.contains("--verbose")
        )
    }

    public func executeScript(named name: String, using archerfile: Archerfile? = nil, with arguments: [String] = []) throws {
        let archerfile = try self.loadArcherfile(archerfile)
        guard let script = archerfile.scripts[name] else {
            throw ArcheryError.undefinedScript(name)
        }
        return try executeScript(
            script,
            using: archerfile,
            with: arguments
        )
    }

    private func loadArcherfile(_ archerfile: Archerfile?) throws -> Archerfile {
        if let archerfile = archerfile {
            return archerfile
        } else {
            return try loadArcherfile(from: Path(archerfileName))
        }
    }

    private func package(for script: Script) -> MintKit.Package {
        return Package(
            repo: script.arrow,
            version: script.version ?? "master",
            name: script.arrow.split(separator: "/").last.map(String.init) ?? script.arrow
        )
    }
}

private func prepareMetadata<T>(_ metadata: T) throws -> String {
    guard let wrapped = try String(data: wrap(metadata), encoding: .utf8) else {
        throw ArcheryError.couldNotPrepareMetadata
    }
    return wrapped.replacingOccurrences(of: "\\/", with: "/")
}
