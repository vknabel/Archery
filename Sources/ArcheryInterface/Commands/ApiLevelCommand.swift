import ArcheryKit

struct ApiLevelCommand: Command {
    func run() throws {
        print(Archery.apiLevel)
    }
}
