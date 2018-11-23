//
//  Metadata.swift
//  ArcheryKitTests
//
//  Created by Valentin Knabel on 21.11.18.
//

import ArcheryKit
import XCTest

class MetadataTests: XCTestCase {
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCanBasicallyBeDecoded() throws {
        let basic = """
        {
        "key": "value"
        }
        """
        let decoder = JSONDecoder()
        let metadata = try decoder.decode(Metadata.self, from: basic.data(using: .utf8)!)
        XCTAssertEqual(metadata, Metadata.dictionary(["key": .string("value")]))
    }

    func testDecodingComplexExample() throws {
        let basic = """
        {
        "scripts": {
        "arrow": "your/Arrow"
        }
        }
        """
        let decoder = JSONDecoder()
        let metadata = try decoder.decode(Metadata.self, from: basic.data(using: .utf8)!)
        XCTAssertEqual(metadata, Metadata.dictionary(["scripts": .dictionary(["arrow": .string("your/Arrow")])]))
    }

    func testCanBasicallyBeEncoded() throws {
        let metadata = Metadata.dictionary(["key": .string("value")])
        let encoder = JSONEncoder()
        let data = try encoder.encode(metadata)
        let expected = try encoder.encode(["key": "value"])
        XCTAssertEqual(String(data: data, encoding: .utf8), String(data: expected, encoding: .utf8))
    }

    func testDecodeFromStringAsYaml() throws {
        let yaml = """
        name: Hello
        """
        let data = try Metadata(string: yaml)
        XCTAssertEqual(data, Metadata.dictionary(["name": .string("Hello")]))
    }
}
