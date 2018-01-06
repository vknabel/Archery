import ArcheryKit

struct VersionCommand: Command {
    func run() throws {
        print(Archery.version)
    }
}
