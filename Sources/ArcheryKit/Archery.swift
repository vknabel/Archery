import ArcherfileDecl
import Foundation
import MintKitShim
import PathKit
import SwiftCLI

public struct Archery {
    private let archerfileName: String
    private let mint: Mint

    public init(archerfileName: String = "Archerfile", mint: Mint = Mint(
        path: "./.archery/mint",
        installationPath: "./.archery/bin"
    )) {
        self.archerfileName = archerfileName
        self.mint = mint
    }

    public func loadArcherfile(from path: Path? = nil) throws -> Archerfile {
        do {
            let archerfileContents = try (path ?? Path(archerfileName)).read() as String
            var plainArcherfile = try Archerfile(string: archerfileContents)
            try! applyAllArcherfileLoaders(&plainArcherfile)
            return plainArcherfile
        } catch let error as NSError
            where error.domain == NSCocoaErrorDomain
            && error.code == NSFileReadNoSuchFileError {
            throw ArcheryError.noArcherfileFound
        }
    }

    public func executeScript(_ script: ScriptDecl, using archerfile: Archerfile, with arguments: [String] = []) throws {
        try ExecutionContext()
            .run(script, using: archerfile, with: arguments)
    }

    public func executeScript(
        named name: String,
        using archerfile: Archerfile? = nil,
        with arguments: [String] = []
    ) throws {
        let archerfile = try loadArcherfile(archerfile, with: arguments)
        guard let script = archerfile.scripts?[name] else {
            throw ArcheryError.undefinedScript(name)
        }
        return try executeScript(
            script,
            using: archerfile,
            with: arguments
        )
    }

    private func applyAllArcherfileLoaders(_ archerfile: inout Archerfile) throws {
        while let loader = archerfile.removeFirstLoader() {
            try applyArcherfileLoader(loader, using: &archerfile)
        }
    }

    private func applyArcherfileLoader(_ loader: ScriptDecl, using archerfile: inout Archerfile) throws {
        try ExecutionContext(silent: true)
            .load(loader, into: &archerfile)
        /* let result = try mint.capture(
         package(for: loader),
         arguments: [
         Archery.apiLevel,
         prepareMetadata(archerfile.metadata),
         prepareMetadata(loader.metadata),
         ],
         verbose: false,
         silent: true
         )
         let additions = try Metadata(string: result.stdout)
         archerfile = try archerfile.loading(additions) */
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
