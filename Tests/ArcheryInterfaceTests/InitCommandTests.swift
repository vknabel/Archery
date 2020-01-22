@testable import ArcheryInterface
import ArcheryKit
import XCTest

final class InitCommandTests: XCTestCase {
    var initCommand: InitCommand!

    override func setUp() {
        initCommand = InitCommand()
    }

    func testArcherfileContentsAreValid() throws {
        let contents = initCommand.archerfileContents(name: "MyTestProject")
        let archerfile = try Archerfile(string: contents)
        XCTAssertEqual(
            archerfile.metadata,
            Metadata(json: [
                "name": "MyTestProject",
                "version": "1.0.0",
                "scripts": [
                    "xcopen": [
                        "command": "swift package generate-xcodeproj && xed .",
                    ],
                ],
                "loaders": [],
            ])
        )
    }
}
