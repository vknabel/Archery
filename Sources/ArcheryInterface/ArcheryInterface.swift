import ArcheryKit

public struct ArcheryInterface {
    public let archery: Archery

    public init(archery: Archery = Archery()) {
        self.archery = archery
    }

    public func run(arguments: [String]) {
        do {
            try command(for: arguments).run()
        } catch {
            print("🏹 Failed with: \(error)")
        }
    }

    private func command(for arguments: [String]) -> Command {
        switch arguments.first {
        case "--version"?:
            return VersionCommand()
        case "--api-level"?:
            return ApiLevelCommand()
        case nil, "help"?, "--help"?:
            return HelpCommand()
        case "init"?:
            return InitCommand()
        case let name?:
            return ExecutionCommand(
                name: name,
                arguments: Array(arguments.dropFirst())
            )
        }
    }
}
