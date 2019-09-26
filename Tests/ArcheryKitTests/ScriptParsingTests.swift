//
//  ScriptParsingTests.swift
//  ArcheryKitTests
//
//  Created by Valentin Knabel on 25.01.18.
//

import ArcherfileDecl
@testable import ArcheryKit
import XCTest

class ScriptParsingTests: XCTestCase {
    private func parseScript(from metadata: Any) throws -> Script {
        let sut = try Script(metadata: Metadata(json: metadata))
        XCTAssertEqual(
            sut.metadata,
            Metadata(json: metadata),
            "Metadata does not loose data"
        )
        return sut
    }

    func testScriptParsingFromMinimalArrow() throws {
        let sut = try parseScript(
            from: [
                "arrow": "some/Arrow",
            ]
        )
        XCTAssertEqual(sut.arrow, "some/Arrow")
    }

    func testScriptParsingFromBashArrow() throws {
        let sut = try parseScript(
            from: [
                "arrow": "cat abc/*.def",
            ]
        )
        XCTAssertEqual(sut.arrow, "vknabel/BashArrow")
        XCTAssertEqual(sut.command, "cat abc/*.def")
    }

    func testScriptParsingFromListOfBashArrow() throws {
        let sut = try parseScript(
            from: "cat abc/*.def"
        )
        XCTAssertEqual(sut.arrow, "vknabel/BashArrow")
        XCTAssertEqual(sut.command, "cat abc/*.def")
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
        XCTAssertEqual(sut.arrow, "some/Arrow")
        XCTAssertEqual(sut.version, "1.0.0")
        XCTAssertEqual(sut.help, "Some helpful tips")
        XCTAssertEqual(sut.nestedArrow, false)
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
        XCTAssertEqual(sut.arrow, "some/Arrow")
        XCTAssertEqual(sut.version, "1.0.0")
        XCTAssertEqual(sut.help, "Some helpful tips")
        XCTAssertEqual(sut.nestedArrow, false)
        XCTAssertEqual(sut.metadata["metaInt"]?.asJSON() as? Decimal, 42)
        XCTAssertEqual(sut.metadata["metaDouble"]?.asJSON() as? Decimal, 1337.1)
        XCTAssertEqual((sut.metadata["metarray"]?.asJSON() as? [Any])?.count, 6)
        XCTAssertEqual((sut.metadata["metaDict"]?.asJSON() as? [String: Any])?.count, 1)
    }

    func testScriptFromInitializer() {
        let sut = Script(arrow: "some/Arrow", version: "1.0.0", help: "My Help", nestedArrow: true)
        XCTAssertEqual(sut.arrow, "some/Arrow")
        XCTAssertEqual(sut.version, "1.0.0")
        XCTAssertEqual(sut.help, "My Help")
        XCTAssertEqual(sut.nestedArrow, true)
        XCTAssertEqual(sut.metadata.asJSONDictionary()?.count, 5)
        XCTAssertEqual(sut.metadata["arrow"]?.asJSON() as? String, sut.arrow)
        XCTAssertEqual(sut.metadata["version"]?.asJSON() as? String, sut.version)
        XCTAssertEqual(sut.metadata["help"]?.asJSON() as? String, sut.help)
        XCTAssertEqual(sut.metadata["nestedArrow"]?.asJSON() as? Bool, sut.nestedArrow)
        XCTAssertNil(sut.metadata["metadata"]?.asJSON())
    }
}
