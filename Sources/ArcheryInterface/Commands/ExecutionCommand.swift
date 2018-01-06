import ArcheryKit

struct ExecutionCommand: Command {
    let name: String
    let arguments: [String]

    init(name: String, arguments: [String]) {
        self.name = name
        self.arguments = arguments
    }

    func run() throws {
        let archery = Archery()
        try archery.executeScript(named: name, with: arguments)
    }
}
