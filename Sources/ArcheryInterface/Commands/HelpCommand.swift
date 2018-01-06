import ArcheryKit

struct HelpCommand: Command {
    func run() throws {
        print("Available Commands:\n")
        for command in try subcommands() {
            if let hint = command.hint {
                print("\t\(command.name)\t\(hint)")
            } else {
                print("\t\(command.name)")
            }
        }
    }

    func subcommands() throws -> [Subcommand] {
        do {
            let archery = Archery()
            let file = try archery.loadArcherfile()
            return file.scripts.map {
                Subcommand(
                    name: $0.0,
                    hint: $0.1.help
                )
            }
        } catch ArcheryError.noArcherfileFound {
            return [
                Subcommand(
                    name: "init",
                    hint: "Creates a new Archerfile"
                ),
            ]
        }
    }

    struct Subcommand {
        let name: String
        let hint: String?
    }
}
