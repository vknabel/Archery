import ArcheryKit
import PathKit

struct InitCommand: Command {
    func run() throws {
        do {
            let archery = Archery()
            try archery.executeScript(named: "init")
        } catch ArcheryError.archerfileNotFound {
            let destination = try createNewArcherfile()
            print("🏹  Created at \(destination)")
        }
    }

    func createNewArcherfile(destination: Path = "Archerfile") throws -> Path {
        try destination.write(
            archerfileContents(name: Path.current.normalize().absolute().lastComponentWithoutExtension)
        )
        return destination
    }
}
