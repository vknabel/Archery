extension Archerfile {
    func legacyMetadata() -> Metadata {
        return metadata.replacing(using: Metadata.dictionary([
            "loaders": .array(loaders.map { $0.legacyMetadata() }),
            "scripts": .dictionary(scripts.mapValues { $0.legacyMetadata() }),
        ]))
    }
}

extension Script {
    func legacyMetadata() -> Metadata {
        return metadata.replacing(using: execution.legacyMetadata())
    }
}

extension ScriptExecution {
    func legacyMetadata() -> Metadata {
        switch self {
        case let .bash(command: cmd):
            return Metadata(json: [
                "arrow": "vknabel/BashArrow",
                "command": cmd,
            ])
        case let .queue(run: run, scripts: scripts):
            return Metadata(json: [
                "arrow": "vknabel/BashArrow",
                "run": run,
                "scripts": scripts.mapValues { $0.legacyMetadata() },
            ] as [String: Any])
        case .legacy:
            return metadata
        }
    }
}
