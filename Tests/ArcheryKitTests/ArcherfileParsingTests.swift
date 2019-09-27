@testable import ArcheryKit
import XCTest

class ArcherfileParsingTests: XCTestCase {
    private func parseArcherfile(from metadata: [String: Any]) throws -> Archerfile {
        let sut = try Archerfile(metadata: Metadata(json: metadata))
        return sut
    }

    func testArcherfileParsingFromMinimalFile() throws {
        let sut = try parseArcherfile(from: [:])
        XCTAssertEqual(sut.scripts.count, 0)
    }

    func testArcherfileParsingFromEmptyScripts() throws {
        let sut = try parseArcherfile(from: [
            "scripts": [:],
        ])
        XCTAssertEqual(sut.scripts.count, 0)
    }

    func testArcherfileParsingFailsFromScriptsArray() {
        XCTAssertThrowsError(try parseArcherfile(from: [
            "scripts": [],
        ]))
        XCTAssertThrowsError(try parseArcherfile(from: [
            "scripts": "abc",
        ]))
        XCTAssertThrowsError(try parseArcherfile(from: [
            "scripts": 1,
        ]))
        XCTAssertThrowsError(try parseArcherfile(from: [
            "scripts": 0.3,
        ]))
        XCTAssertThrowsError(try parseArcherfile(from: [
            "scripts": false,
        ]))
    }

    func testArcherfileParsingFromSomeScripts() throws {
        let sut = try parseArcherfile(from: [
            "scripts": [
                "some": [
                    "arrow": "my/Arrow",
                ],
                "other": [
                    "arrow": "your/Arrow",
                ],
            ],
        ])
        XCTAssertEqual(sut.scripts["some"]?.execution.legacy?.arrow, "my/Arrow")
        XCTAssertEqual(sut.scripts["other"]?.execution.legacy?.arrow, "your/Arrow")
    }

    func testArcherfileParsingFromSomeScriptsAndShorthand() throws {
        let sut = try parseArcherfile(from: [
            "scripts": [
                "some": [
                    "arrow": "my/Arrow",
                ],
                "other": "your/Arrow",
            ],
        ])
        XCTAssertEqual(sut.scripts["some"]?.execution.legacy?.arrow, "my/Arrow")
        XCTAssertEqual(sut.scripts["other"]?.execution.legacy?.arrow, "your/Arrow")
    }

    func testArcherfileParsingFromSomeLoadersAndShorthand() throws {
        let sut = try parseArcherfile(from: [
            "loaders": [
                [
                    "arrow": "my/Arrow",
                ],
                "your/Arrow",
            ],
        ])
        XCTAssertEqual(sut.loaders[0].execution.legacy?.arrow, "my/Arrow")
        XCTAssertEqual(sut.loaders[1].execution.legacy?.arrow, "your/Arrow")
    }

    func testArcherfileParsingFromSomeLoadersAndBashShorthand() throws {
        let sut = try parseArcherfile(from: [
            "loaders": [
                "cat Metadata/*.yml",
            ],
        ])
        XCTAssertEqual(sut.loaders[0].execution.bashCommand, "cat Metadata/*.yml")
    }
}
