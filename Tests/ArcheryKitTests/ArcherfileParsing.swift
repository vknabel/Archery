//
//  ArcherfileParsing.swift
//  ArcheryInterfaceTests
//
//  Created by Valentin Knabel on 25.01.18.
//

@testable import ArcheryKit
import XCTest

class ArcherfileParsing: XCTestCase {
    private func parseArcherfile(from metadata: [String: Any]) throws -> Archerfile {
        let sut = try Archerfile(metadata: Metadata(json: metadata))
        let serializationOptions = [.prettyPrinted] as JSONSerialization.WritingOptions
        XCTAssertEqual(
            try? String(data: JSONSerialization.data(withJSONObject: sut.metadata.asJSON()!, options: serializationOptions), encoding: .utf8),
            try? String(data: JSONSerialization.data(withJSONObject: metadata, options: serializationOptions), encoding: .utf8),
            "Metadata does not loose data"
        )
        return sut
    }

    func testArcherfileParsingFromMinimalFile() throws {
        let sut = try parseArcherfile(from: [:])
        XCTAssertEqual(sut.value.scripts.count, 0)
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

    func testArcherfileParsingFromSomeLoadersAndShorthand() throws {
        let sut = try parseArcherfile(from: [
            "loaders": [
                [
                    "arrow": "my/Arrow",
                ],
                "your/Arrow",
            ],
        ])
        XCTAssertEqual(sut.loaders[0].arrow, "my/Arrow")
        XCTAssertEqual(sut.loaders[1].arrow, "your/Arrow")
    }

    func testArcherfileParsingFromSomeLoadersAndBashShorthand() throws {
        let sut = try parseArcherfile(from: [
            "loaders": [
                "cat Metadata/*.yml",
            ],
        ])
        XCTAssertEqual(sut.loaders[0].arrow, "vknabel/BashArrow")
        XCTAssertEqual(sut.loaders[0].command, "cat Metadata/*.yml")
    }
}
