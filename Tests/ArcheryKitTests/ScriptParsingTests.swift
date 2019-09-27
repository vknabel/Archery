@testable import ArcheryKit
import XCTest

class ScriptParsingTests: XCTestCase {
    private func parseScript(from metadata: Any) throws -> Script {
        let sut = try Script(metadata: Metadata(json: metadata))
        return sut
    }

    func testScriptParsingFromMinimalArrow() throws {
        let sut = try parseScript(
            from: [
                "arrow": "some/Arrow",
            ]
        )
        XCTAssertEqual(sut.execution.legacy?.arrow, "some/Arrow")
    }

    func testScriptParsingFromListOfBashArrow() throws {
        let sut = try parseScript(
            from: "cat abc/*.def"
        )
        XCTAssertEqual(sut.execution.bashCommand, "cat abc/*.def")
    }

    func testScriptParsingFailsFromMinimalArrowWithComplexRepo() {
        XCTAssertThrowsError(try parseScript(from: [:]))
        XCTAssertThrowsError(
            try parseScript(
                from: [
                    "arrow": [],
                ]
            )
        )
        XCTAssertThrowsError(
            try parseScript(
                from: [
                    "arrow": [:],
                ]
            )
        )
    }

    func testScriptParsingFromFullScript() throws {
        let sut = try parseScript(
            from: [
                "arrow": "some/Arrow",
                "version": "1.0.0",
                "help": "Some helpful tips",
                "nestedArrow": false,
            ]
        )
        XCTAssertEqual(sut.execution.legacy?.arrow, "some/Arrow")
        XCTAssertEqual(sut.execution.legacy?.version, "1.0.0")
        XCTAssertEqual(sut.help, "Some helpful tips")
        XCTAssertEqual(sut.execution.legacy?.nestedArrow, false)
    }

    func testScriptParsingFromFullScriptIncludingMetadata() throws {
        let sut = try parseScript(
            from: [
                "arrow": "some/Arrow",
                "version": "1.0.0",
                "help": "Some helpful tips",
                "nestedArrow": false,
                "metaInt": 42,
                "metaDouble": 1337.1,
                "metarray": ["first", true, 3.0, 32, nil, ["and": "last"]],
                "metaDict": ["just": 1],
            ]
        )
        XCTAssertEqual(sut.execution.legacy?.arrow, "some/Arrow")
        XCTAssertEqual(sut.execution.legacy?.version, "1.0.0")
        XCTAssertEqual(sut.help, "Some helpful tips")
        XCTAssertEqual(sut.execution.legacy?.nestedArrow, false)
        XCTAssertEqual(sut.metadata["metaInt"]?.asJSON() as? Decimal, 42)
        XCTAssertEqual(sut.metadata["metaDouble"]?.asJSON() as? Decimal, 1337.1)
        XCTAssertEqual((sut.metadata["metarray"]?.asJSON() as? [Any])?.count, 6)
        XCTAssertEqual((sut.metadata["metaDict"]?.asJSON() as? [String: Any])?.count, 1)
    }
}
