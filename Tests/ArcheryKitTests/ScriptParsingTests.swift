//
//  ScriptParsingTests.swift
//  ArcheryKitTests
//
//  Created by Valentin Knabel on 25.01.18.
//

@testable import ArcheryKit
import class Unbox.Unboxer
import XCTest

class ScriptParsingTests: XCTestCase {

    private func parseScript(from metadata: [String: Any]) throws -> Script {
        let sut = try Script(unboxer: Unboxer(dictionary: metadata))
        let serializationOptions = [.prettyPrinted] as JSONSerialization.WritingOptions
        XCTAssertEqual(
            try? JSONSerialization.data(withJSONObject: sut.metadata, options: serializationOptions),
            try? JSONSerialization.data(withJSONObject: metadata, options: serializationOptions),
            "Metadata does not loose data"
        )
        return sut
    }

    func testScriptParsingFromMinimalArrow() throws {
        let sut = try parseScript(from: [
            "arrow": "some/Arrow",
        ])
        XCTAssertEqual(sut.arrow, "some/Arrow")
    }

    func testScriptParsingFailsFromMinimalArrowWithComplexRepo() {
        XCTAssertThrowsError(try parseScript(from: [:]))
        XCTAssertThrowsError(try parseScript(from: [
            "arrow": [],
        ]))
        XCTAssertThrowsError(try parseScript(from: [
            "arrow": [:],
        ]))
    }

    func testScriptParsingFromFullScript() throws {
        let sut = try parseScript(from: [
            "arrow": "some/Arrow",
            "version": "1.0.0",
            "help": "Some helpful tips",
            "nestedArrow": false,
        ])
        XCTAssertEqual(sut.arrow, "some/Arrow")
        XCTAssertEqual(sut.version, "1.0.0")
        XCTAssertEqual(sut.help, "Some helpful tips")
        XCTAssertEqual(sut.nestedArrow, false)
    }

    func testScriptParsingFromFullScriptIncludingMetadata() throws {
        let sut = try parseScript(from: [
            "arrow": "some/Arrow",
            "version": "1.0.0",
            "help": "Some helpful tips",
            "nestedArrow": false,
            "metaInt": 42,
            "metaDouble": 1337.0,
            "metarray": ["first", true, 3.0, 32, nil, ["and": "last"]],
            "metaDict": ["just": 1],
        ])
        XCTAssertEqual(sut.arrow, "some/Arrow")
        XCTAssertEqual(sut.version, "1.0.0")
        XCTAssertEqual(sut.help, "Some helpful tips")
        XCTAssertEqual(sut.nestedArrow, false)
        XCTAssertEqual(sut.metadata["metaInt"] as? Int, 42)
        XCTAssertEqual(sut.metadata["metaDouble"] as? Double, 1337.0)
        XCTAssertEqual((sut.metadata["metarray"] as? [Any])?.count, 6)
        XCTAssertEqual((sut.metadata["metaDict"] as? [String: Any])?.count, 1)
    }

    func testScriptFromInitializer() {
        let sut = Script(arrow: "some/Arrow", version: "1.0.0", help: "My Help", nestedArrow: true)
        XCTAssertEqual(sut.arrow, "some/Arrow")
        XCTAssertEqual(sut.version, "1.0.0")
        XCTAssertEqual(sut.help, "My Help")
        XCTAssertEqual(sut.nestedArrow, true)
        XCTAssertEqual(sut.metadata.count, 4)
        XCTAssertEqual(sut.metadata["arrow"] as? String, sut.arrow)
        XCTAssertEqual(sut.metadata["version"] as? String, sut.version)
        XCTAssertEqual(sut.metadata["help"] as? String, sut.help)
        XCTAssertEqual(sut.metadata["nestedArrow"] as? Bool, sut.nestedArrow)
        XCTAssertNil(sut.metadata["metadata"])
    }
}
