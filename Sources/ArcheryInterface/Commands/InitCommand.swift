import ArcheryKit
import PathKit

struct InitCommand: Command {
    func run() throws {
        do {
            let archery = Archery()
            try archery.executeScript(named: "init")
        } catch ArcheryError.noArcherfileFound {
            let destination = try createNewArcherfile()
            print("🏹  Created at \(destination)")
        }
    }

    func createNewArcherfile() throws -> Path {
        return "Archerfile"
    }
}
