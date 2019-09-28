import Foundation

struct Settings {
    var env: [String: String] = [:]
    var defaultLaunchPath = "/usr/bin/env"

    var defaultWorkingDirectory = FileManager.default.currentDirectoryPath
    var defaultEnv = ProcessInfo.processInfo.environment

    var legacyMintPath = "mint"
}

struct ExecutionContext {
    var settings: Settings

    var silent: Bool = false
    var env: [String: String] = [:]
    var launchPath: String?
    var workingDirectory: String?

    init(
        settings: Settings = Settings(),
        silent: Bool = false,
        env: [String: String] = [:],
        launchPath: String? = nil,
        workingDirectory: String? = nil
    ) {
        self.settings = settings
        self.silent = silent
        self.env = env
        self.launchPath = launchPath
        self.workingDirectory = workingDirectory
    }

    func run(_ script: LabeledScript, using archerfile: Archerfile, with arguments: [String]) throws {
        let processes = try makeProcesses(script, using: archerfile, with: arguments, parentScripts: [:])
        for (label, process) in processes {
            if !silent {
                print("🏹  Running \(label.joined(separator: " ▶︎ "))")
            }

            try process.runAndWait()
            if process.terminationStatus != 0 {
                throw ArcheryError.executionFailed(label: label, status: process.terminationStatus)
            }
        }
    }

    func load(_ script: LabeledScript, into archerfile: inout Archerfile, with arguments: [String]) throws {
        // Queue loaders will be executed using the same archerfile definition!
        let processes = try makeProcesses(script, using: archerfile, with: arguments, parentScripts: [:])
        for (label, process) in processes {
            let inputPipe = FileHandle.nullDevice
            let outputPipe = Pipe()
            let errorPipe = FileHandle.standardError
            process.standardInput = inputPipe
            process.standardOutput = outputPipe
            process.standardError = errorPipe

            try process.runAndWait()
            if process.terminationStatus != 0 {
                throw ArcheryError.executionFailed(label: label, status: process.terminationStatus)
            }

            let output = String(data: outputPipe.fileHandleForReading.availableData, encoding: .utf8)
            let additionalMetadata = try output.map(Metadata.init(string:)) ?? .dictionary([:])
            try archerfile.loading(additions: additionalMetadata)
        }
    }

    private func makeProcesses(
        _ labeled: LabeledScript,
        using archerfile: Archerfile,
        with arguments: [String],
        parentScripts: [String: Script]
    ) throws -> [(label: [String], process: Process)] {
        switch labeled.script.execution {
        case let .bash(command: cmd):
            let process = try makeBaseProcess(for: labeled.script, using: archerfile)
            process.arguments = ["bash", "-c", cmd, targetWorkingDirectory(for: labeled.script)] + arguments
            return [(labeled.label, process)]
        case let .legacy(arrow: arrow, version: version, nestedArrow: nested):
            let packageName = arrow.split(separator: "/").last.map(String.init) ?? arrow
            let encoder = JSONEncoder()
            let legacyArguments = [
                "1",
                String(data: try encoder.encode(archerfile.legacyMetadata()), encoding: .utf8) ?? "{}",
                String(data: try encoder.encode(labeled.script.legacyMetadata()), encoding: .utf8) ?? "{}",
            ]
            let nestedArrowArguments = nested ?? false ? legacyArguments : []
            let silenceArguments = silent ? ["--silent"] : []
            let legacyEnvironment = [
                // fake the old API level
                "ARCHERY_API_LEVEL": "1",
                "ARCHERY_LEGACY_MINT_PATH": settings.legacyMintPath,
            ]
            let versionedArrow = version.map({ "\(arrow)@\($0)" }) ?? arrow

            let process = try makeBaseProcess(for: labeled.script, using: archerfile)
            process.environment?.merge(legacyEnvironment, uniquingKeysWith: { $1 })
            process.arguments = combineArguments(
                [settings.legacyMintPath, "run"],
                silenceArguments,
                [versionedArrow, packageName],
                legacyArguments,
                nestedArrowArguments,
                arguments
            )
            return [(labeled.label, process)]
        case let .queue(run: runOrder, scripts: localScripts):
            let orderedScripts = try runOrder.map { name -> LabeledScript in
                guard let match = localScripts[name] ?? parentScripts[name] ?? archerfile.scripts[name] else {
                    throw ArcheryError.scriptNotFound(name: name, label: labeled.label)
                }
                return match.labeled(by: labeled.label + [name])
            }
            let combinedScripts = parentScripts.merging(localScripts, uniquingKeysWith: { _, local in local })
            return try orderedScripts.flatMap { namedScript -> [(label: [String], process: Process)] in
                let (label, current) = namedScript
                return try makeProcesses(
                    current.labeled(by: label),
                    using: archerfile,
                    with: arguments,
                    parentScripts: combinedScripts
                )
            }
        }
    }

    private func makeBaseProcess(for script: Script, using archerfile: Archerfile) throws -> Process {
        let encoder = JSONEncoder()
        let archeryEnv: [String: String] = [
            "ARCHERY": CommandLine.arguments[0],
            "ARCHERY_API_LEVEL": "2",
            "ARCHERY_METADATA": String(data: try encoder.encode(archerfile), encoding: .utf8) ?? "{}",
            "ARCHERY_SCRIPT": String(data: try encoder.encode(script), encoding: .utf8) ?? "{}",
        ]

        let process = Process()
        if #available(macOS 10.13, *) {
            process.executableURL = URL(fileURLWithPath: launchPath ?? settings.defaultLaunchPath)
            process.currentDirectoryURL = URL(fileURLWithPath: targetWorkingDirectory(for: script))
        } else {
            process.launchPath = launchPath ?? settings.defaultLaunchPath
            process.currentDirectoryPath = targetWorkingDirectory(for: script)
        }

        process.environment = ProcessInfo.processInfo.environment
            .merging(archeryEnv, uniquingKeysWith: { $1 })
            .merging(env, uniquingKeysWith: { $1 })
            .merging(script.env ?? [:], uniquingKeysWith: { $1 })
        return process
    }

    private func targetWorkingDirectory(for script: Script) -> String {
        return script.workingDirectory
            ?? workingDirectory
            ?? settings.defaultWorkingDirectory
    }
}

private func combineArguments(_ arguments: [String]...) -> [String] {
    return arguments.flatMap { $0 }
}

private extension Process {
    func runAndWait() throws {
        try ProcessScheduler.run(self)
        waitUntilExit()
    }
}
