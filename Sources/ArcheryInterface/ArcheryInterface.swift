import ArcheryKit
import Foundation
import protocol SwiftCLI.ProcessError
import enum Unbox.UnboxError

public struct ArcheryInterface {
    public let archery: Archery

    public init(archery: Archery = Archery()) {
        self.archery = archery
    }

    public func run(arguments: [String]) -> Never {
        do {
            try command(for: arguments).run()
            exit(0)
        } catch let error as ArcheryError {
            print("💥  \(error)")
            exit(1)
        } catch let error as NSError where error.domain == NSCocoaErrorDomain {
            print("💥  \(error.localizedDescription)")
            exit(1)
        } catch let error as ProcessError {
            exit(Int32(error.exitStatus))
        } catch let UnboxError.pathError(path, _) {
            print("💥  \(path)")
            exit(1)
        } catch is UnboxError {
            print("💥  Invalid format for Archerfile")
            exit(1)
        } catch {
            print("💥  \(error)")
            exit(1)
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
