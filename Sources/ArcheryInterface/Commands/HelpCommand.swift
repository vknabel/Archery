import ArcheryKit

struct HelpCommand: Command {
    let prefix = "    "
    let padding = "  "
    func run() throws {
        let (archerfile, allSubcommands) = try context()
        if let help = archerfile.metadata["help"] as? String {
            print(help + "\n")
        }
        print("Available Commands:\n")
        let maxLength = allSubcommands.map { $0.name.count }
            .max() ?? 0
        for command in allSubcommands {
            if let hint = command.hint {
                let fullPadding = String(repeating: " ", count: maxLength) + prefix
                let additionalPadding = String(repeating: " ", count: maxLength - command.name.count)
                let indentedHelp = hint.replacingOccurrences(of: "\n", with: "\n" + padding + fullPadding)
                print(prefix + command.name + padding + additionalPadding + indentedHelp)
            } else {
                print(prefix + command.name)
            }
        }
    }

    func context() throws -> (Archerfile, [Subcommand]) {
        do {
            let archery = Archery()
            let file = try archery.loadArcherfile()
            return (file, file.scripts.map {
                Subcommand(
                    name: $0.0,
                    hint: $0.1.help
                )
            }.sorted(by: { $0.name < $1.name }))
        } catch ArcheryError.noArcherfileFound {
            return (try Archerfile(metadata: [:]), [
                Subcommand(
                    name: "init",
                    hint: "Creates a new Archerfile"
                ),
            ])
        }
    }

    struct Subcommand {
        let name: String
        let hint: String?
    }
}
