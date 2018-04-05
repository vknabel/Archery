//
//  ArcherfileParsing.swift
//  ArcheryInterfaceTests
//
//  Created by Valentin Knabel on 25.01.18.
//

@testable import ArcheryKit
import Unbox
import XCTest

class ArcherfileParsing: XCTestCase {
    private func parseArcherfile(from metadata: [String: Any]) throws -> Archerfile {
        let sut = try Archerfile(unboxer: Unboxer(dictionary: metadata))
        let serializationOptions = [.prettyPrinted] as JSONSerialization.WritingOptions
        XCTAssertEqual(
            try? JSONSerialization.data(withJSONObject: sut.metadata, options: serializationOptions),
            try? JSONSerialization.data(withJSONObject: metadata, options: serializationOptions),
            "Metadata does not loose data"
        )
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
        XCTAssertEqual(sut.scripts["some"]?.arrow, "my/Arrow")
        XCTAssertEqual(sut.scripts["other"]?.arrow, "your/Arrow")
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
        XCTAssertEqual(sut.scripts["some"]?.arrow, "my/Arrow")
        XCTAssertEqual(sut.scripts["other"]?.arrow, "your/Arrow")
    }
}
