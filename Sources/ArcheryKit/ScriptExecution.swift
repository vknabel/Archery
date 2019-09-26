import ArcherfileDecl
import Foundation

struct Settings {
    var env: [String: String] = [:]
    var defaultLaunchPath = "/usr/bin/env"

    var defaultWorkingDirectory = FileManager.default.currentDirectoryPath
    var defaultEnv = ProcessInfo.processInfo.environment

    var legacyMintPath = "mint"
}

struct ExecutionContext {
    var settings = Settings()

    var silent: Bool = false
    var env: [String: String] = [:]
    var launchPath: String?
    var workingDirectory: String?

    func run(_ script: ScriptDecl, using archerfile: Archerfile, with arguments: [String]) throws {
        let processes = try makeProcesses(for: script, using: archerfile, with: arguments, parentScripts: [:])
        for process in processes {
            process.launch()
            process.waitUntilExit()
            // TODO: throw on error
        }
    }

    func load(_ script: ScriptDecl, into archerfile: inout Archerfile) throws {
        // Queue loaders will be executed using the same archerfile definition!
        let processes = try makeProcesses(for: script, using: archerfile, with: [], parentScripts: [:])
        for process in processes {
            let inputPipe = FileHandle.nullDevice
            let outputPipe = Pipe()
            let errorPipe = FileHandle.standardError
            process.standardInput = inputPipe
            process.standardOutput = outputPipe
            process.standardError = errorPipe

            process.launch()
            process.waitUntilExit()
            // TODO: throw error?

            let output = String(data: outputPipe.fileHandleForReading.availableData, encoding: .utf8)
            let additionalMetadata = try Metadata(string: output ?? "{}")
            try archerfile.loading(additions: additionalMetadata)
        }
    }

    private func makeProcesses(for script: ScriptDecl, using archerfile: Archerfile, with arguments: [String], parentScripts: [String: ScriptDecl]) throws -> [Process] {
        switch script.execution {
        case let .bash(command: cmd):
            let process = try makeBaseProcess(for: script, using: archerfile)
            process.arguments = ["bash", "-c", cmd]
            return [process]
        case let .legacy(arrow: arrow, version: version, nestedArrow: nested):
            let packageName = arrow.split(separator: "/").last.map(String.init) ?? arrow
            let legacyArguments = [String]()
            let nestedArrowArguments = nested ?? false ? legacyArguments : []
            let arguments = [String]()
            let silenceArguments = silent ? ["--silent"] : []
            let legacyEnvironment = [
                "ARCHERY_API_LEVEL": "1", // fake old API level
                "ARCHERY_LEGACY_MINT_PATH": "mint",
                "ARCHERY_LEGACY_SILENCE_FLAG": silent ? "--silence" : "",
            ]
            let versionedArrow = version.map({ "\(arrow)@\($0)" }) ?? arrow

            let process = try makeBaseProcess(for: script, using: archerfile)
            process.environment?.merge(legacyEnvironment, uniquingKeysWith: { $1 })
            process.launchPath = "/usr/bin/env"
            process.arguments = combine(arguments:
                [settings.legacyMintPath, "run"],
                                        silenceArguments,
                                        [versionedArrow, packageName],
                                        legacyArguments,
                                        nestedArrowArguments,
                                        arguments)
            return [process]
        case let .queue(run: runOrder, scripts: localScripts):
            let orderedScripts = runOrder.map { name -> ScriptDecl in
                guard let match = localScripts[name] ?? parentScripts[name] ?? archerfile.scripts?[name] else {
                    fatalError("Throw not found error and tell which scripts are known")
                }
                return match
            }
            let combinedScripts = parentScripts.merging(localScripts, uniquingKeysWith: { _, local in local })
            return try orderedScripts.flatMap { current in
                try makeProcesses(for: current, using: archerfile, with: arguments, parentScripts: combinedScripts)
            }
        }
    }

    private func makeBaseProcess(for script: ScriptDecl, using archerfile: Archerfile) throws -> Process {
        let encoder = JSONEncoder()
        let archeryEnv: [String: String] = [
            "ARCHERY_API_LEVEL": "2",
            "ARCHERY_METADATA": String(data: try encoder.encode(archerfile), encoding: .utf8) ?? "{}",
            "ARCHERY_SCRIPT": String(data: try encoder.encode(script), encoding: .utf8) ?? "{}",
        ]
        // "$ARCHERY_MINT_PATH" run $ARCHER_LEGACY_SILENCE_FLAG '\#(arrow)@\#(version ?? "master")' '\#(packageName)' "$ARCHERY_API_LEVEL" "$ARCHERY_METADATA" "$ARCHERY_SCRIPT"

        let process = Process()
        process.launchPath = launchPath ?? settings.defaultLaunchPath
        process.currentDirectoryPath = workingDirectory ?? settings.defaultWorkingDirectory
        // TODO: process.currentDirectoryPath
        process.environment = ProcessInfo.processInfo.environment
            .merging(archeryEnv, uniquingKeysWith: { $1 })
            .merging(env, uniquingKeysWith: { $1 })
            .merging(script.env ?? [:], uniquingKeysWith: { $1 })
        return process
    }
}

private func combine(arguments: [String]...) -> [String] {
    return arguments.flatMap { $0 }
}
