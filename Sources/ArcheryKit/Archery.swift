import Foundation

public struct Archery {
    private let archerfileName: String
    private let environment: [String: String]

    public init(
        archerfileName: String = "Archerfile",
        environment: [String: String] = ProcessInfo.processInfo.environment
    ) {
        self.archerfileName = archerfileName
        self.environment = environment
    }

    public func loadArcherfile(
        from path: Path? = nil,
        with arguments: [String]
    ) throws -> Archerfile {
        do {
            let archerfileContents = try environment["ARCHERY_METADATA"]
                ?? (path ?? Path(archerfileName)).read() as String
            var plainArcherfile = try Archerfile(string: archerfileContents)
            try applyAllArcherfileLoaders(&plainArcherfile, with: arguments)
            return plainArcherfile
        } catch let error as NSError
            where error.domain == NSCocoaErrorDomain
            && error.code == NSFileReadNoSuchFileError {
            throw ArcheryError.archerfileNotFound
        }
    }

    public func executeScript(
        named name: String,
        using archerfile: Archerfile? = nil,
        with arguments: [String] = []
    ) throws {
        let archerfile = try loadArcherfile(archerfile, with: arguments)
        guard let script = archerfile.scripts[name]?.labeled(by: ["scripts", name]) else {
            throw ArcheryError.scriptNotFound(name: name, label: ["scripts"])
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

    private func applyAllArcherfileLoaders(_ archerfile: inout Archerfile, with arguments: [String]) throws {
        for index in 0... {
            guard let loader = archerfile.removeFirstLoader() else {
                return
            }
            try applyArcherfileLoader(
                loader.labeled(by: ["loaders", "step \(index)"]),
                using: &archerfile,
                with: arguments
            )
        }
    }

    private func applyArcherfileLoader(
        _ loader: LabeledScript,
        using archerfile: inout Archerfile,
        with arguments: [String]
    ) throws {
        try ExecutionContext(silent: true)
            .load(loader, into: &archerfile, with: arguments)
    }

    private func loadArcherfile(
        _ archerfile: Archerfile?,
        with arguments: [String]
    ) throws -> Archerfile {
        if let archerfile = archerfile {
            return archerfile
        } else {
            return try loadArcherfile(from: Path(archerfileName), with: arguments)
        }
    }
}
